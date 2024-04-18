# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="14f0776550b5a49e1c42f49a00213f7f3fa047bf"
CROS_WORKON_TREE="61008e62ee9355dc4f54966bb66709274963c4ad"
PYTHON_COMPAT=( python3_{8..11} )

CROS_WORKON_REPO="${CROS_GIT_HOST_URL}"
CROS_WORKON_PROJECT="external/github.com/llvm/llvm-project"
CROS_WORKON_LOCALNAME="llvm-project"

# When building the 9999 ebuild, cros-workon will `rsync --exclude=.git` the
# project, so we don't have access to the git repository. When building a
# versioned ebuild, cros-workon will create a shallow clone that has a .git
# directory. So we need to use the PRECLONE_HOOK in the 9999 case to calculate
# the SVN revision.
if [[ "${PV}" == "9999" ]]; then
	# shellcheck disable=SC2034
	CROS_WORKON_PRECLONE_HOOK="cros-llvm_default_preclone_hook"
fi

# We have to inherit cros-workon after we set up the CROS_WORKON_* variables.

inherit cmake-multilib cros-constants cros-llvm git-2 python-any-r1 toolchain-funcs cros-workon

DESCRIPTION="New implementation of the C++ standard library, targeting C++11"
HOMEPAGE="http://libcxx.llvm.org/"
SRC_URI=""

EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project
	${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project"
EGIT_BRANCH=main

# TODO(b/267209587): Remove LLVM_HASH as it's no longer used.
# shellcheck disable=SC2034
LLVM_HASH="14f0776550b5a49e1c42f49a00213f7f3fa047bf" # r498229
LLVM_NEXT_HASH="82e851a407c52d65ce65e7aa58453127e67d42a0" # r510928

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="+compiler-rt cros_host elibc_glibc elibc_musl +libcxxabi libcxxrt +libunwind msan +static-libs continue-on-patch-failure"
if [[ "${PV}" != "9999" ]]; then
	IUSE+=" llvm-next"
fi
REQUIRED_USE="libunwind? ( || ( libcxxabi libcxxrt ) )
	?? ( libcxxabi libcxxrt )"

# MULTILIB_USEDEP is defined in an eclass, which shellcheck won't see
# shellcheck disable=SC2154
RDEPEND="
	libunwind? ( ${CATEGORY}/llvm-libunwind )
	libcxxrt? ( ${CATEGORY}/libcxxrt[libunwind=,static-libs?,${MULTILIB_USEDEP}] )
	!cros_host? ( sys-libs/gcc-libs )
"
DEPEND="${RDEPEND}"

if [[ "${CATEGORY}" == cross-*-linux* ]]; then
	DEPEND+="
		${CATEGORY}/linux-headers
		${CATEGORY}/glibc
	"
elif [[ "${CATEGORY}" == cross-* ]]; then
	DEPEND+="
		${CATEGORY}/newlib
	"
else
	DEPEND+="
		sys-kernel/linux-headers
		sys-libs/glibc
	"
fi

BDEPEND="
	sys-devel/llvm
	${PYTHON_DEPS}
"

if [[ "${CATEGORY}" == cross-* ]]; then
	# The x86 compiler-rt is provided by sys-devel/llvm.
	if [[ "${CATEGORY}" != cross-x86_64-* && "${CATEGORY}" != cross-i686-* ]]; then
		BDEPEND+="
			compiler-rt? ( ${CATEGORY}/compiler-rt )
		"
	fi
fi

src_unpack() {
	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next; then
			CROS_WORKON_COMMIT=("${LLVM_NEXT_HASH}") # portage_util: no edit
			CROS_WORKON_TREE=() # portage_util: no edit
		fi
	fi
	cros-workon_src_unpack
}

src_prepare() {
	python_setup
	local failure_mode
	failure_mode="$(usex continue-on-patch-failure continue fail)"
	local most_recent_revision
	# This file may be created by CROS_WORKON_PRECLONE_HOOK
	if [[ -f "${T}/llvm-rev" ]]; then
		# If this file exists, it was set by the unpack stage.
		most_recent_revision="$(<"${T}/llvm-rev")"
	else
		most_recent_revision="$(get_most_recent_revision)"
	fi
	"${FILESDIR}"/patch_manager/patch_manager.py \
		--svn_version "${most_recent_revision}" \
		--patch_metadata_file "${FILESDIR}"/PATCHES.json \
		--failure_mode "${failure_mode}" \
		--src_path "${S}" || die

	eapply_user
	cmake_src_prepare
}

pkg_setup() {
	setup_cross_toolchain
	export CMAKE_USE_DIR="${S}/runtimes"
}

multilib_src_configure() {
	# Filter sanitzers flags.
	filter_sanitizers

	cros_optimize_package_for_speed

	local cxxabi
	if use libcxxabi; then
		cxxabi=libcxxabi
	fi
	# Use vfpv3 to be able to target non-neon targets.
	# shellcheck disable=SC2154 # CTARGET is assigned elsewhere.
	if [[ "${CTARGET}" == armv7a* ]] ; then
		append-flags -mfpu=vfpv3
	fi

	# we want -lgcc_s for unwinder, and for compiler runtime when using
	# gcc, clang with gcc runtime (or any unknown compiler)
	local extra_libs=() want_gcc_s=ON
	if use libunwind || use compiler-rt; then
		# work-around missing -lunwind upstream
		use libunwind && extra_libs+=( -lunwind )
		# if we're using libunwind and clang with compiler-rt, we want
		# to link to compiler-rt instead of -lgcc_s
		if tc-is-clang; then
			# get the full library list out of 'pretend mode'
			# and grep it for libclang_rt references
			local args
			IFS=" " read -r -a args <<< "$($(tc-getCC) -### -x c - 2>&1 | tail -n 1)"
			local i
			for i in "${args[@]}"; do
				if [[ ${i} == *libclang_rt* ]]; then
					want_gcc_s=OFF
					extra_libs+=( "${i}" )
				fi
			done
		fi
	fi

	# Link with libunwind.so.
	use libunwind && append-ldflags "-shared-libgcc"

	# Enable futex in libc++abi to match prod toolchain.
	append-cppflags -D_LIBCXXABI_USE_FUTEX
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"-DLIBCXX_LIBDIR_SUFFIX=${libdir#lib}"
		"-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
		"-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
		"-DLIBCXX_ENABLE_SHARED=ON"
		"-DLIBCXX_ENABLE_STATIC=$(usex static-libs)"
		"-DLIBCXX_INCLUDE_BENCHMARKS=OFF"
		# we're using our own mechanism for generating linker scripts
		"-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF"
		"-DLIBCXX_HAS_MUSL_LIBC=$(usex elibc_musl)"
		"-DLIBCXX_HAS_GCC_S_LIB=${want_gcc_s}"
		"-DLIBCXX_USE_COMPILER_RT=$(usex compiler-rt)"
		"-DLIBCXX_INCLUDE_TESTS=OFF"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
		"-DCMAKE_SHARED_LINKER_FLAGS=${extra_libs[*]} ${LDFLAGS}"
		"-DLIBCXX_HAS_ATOMIC_LIB=OFF"
		"-DCMAKE_C_COMPILER_TARGET=$(get_abi_CTARGET)"
		"-DCMAKE_CXX_COMPILER_TARGET=$(get_abi_CTARGET)"
		"-DLLVM_ENABLE_RUNTIMES=libcxxabi;libcxx"
		"-DLIBCXX_CXX_ABI=${cxxabi}"
		"-DLIBCXXABI_USE_LLVM_UNWINDER=$(usex libunwind)"
		"-DLIBCXXABI_LIBDIR_SUFFIX=${libdir#lib}"
		"-DLIBCXXABI_ENABLE_SHARED=ON"
		"-DLIBCXXABI_ENABLE_STATIC=$(usex static-libs)"
		"-DLIBCXXABI_INCLUDE_TESTS=OFF"
		"-DLIBCXXABI_USE_COMPILER_RT=$(usex compiler-rt)"
	)
	if use msan; then
		mycmakeargs+=(
			"-DLLVM_USE_SANITIZER=Memory"
		)
	fi

	if is_baremetal_abi; then
		# Options for baremetal toolchains e.g. armv7m-cros-eabi.
		# Disable stack allocation and features like posix_memalign.
		append-cppflags "-D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION"
		# Compilation with newlib as C standard library fails unless
		# -D_GNU_SOURCE is defined.
		append-cppflags "-D_GNU_SOURCE"
		# Disable assertions
		# TODO: this seems to do more than LIBCXX_ENABLE_ASSERTIONS=off - why?)
		append-cppflags "-DNDEBUG"
		append-flags -Oz # Optimize for smallest size.
		mycmakeargs+=(
			"-DCMAKE_POSITION_INDEPENDENT_CODE=OFF"
			"-DLIBCXXABI_ENABLE_SHARED=OFF"
			"-DLIBCXXABI_BAREMETAL=ON"
			"-DLIBCXXABI_SILENT_TERMINATE=ON"
			"-DLIBCXXABI_NON_DEMANGLING_TERMINATE=ON"
			"-DLIBCXXABI_ENABLE_THREADS=OFF"
			"-DLIBCXX_ENABLE_SHARED=OFF"
			"-DLIBCXX_ENABLE_RANDOM_DEVICE=OFF"
			"-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=OFF"
			"-DLIBCXX_ENABLE_UNICODE=OFF"
			"-DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF"
			"-DLIBCXX_ENABLE_FILESYSTEM=OFF"
			"-DLIBCXX_ENABLE_THREADS=OFF"
			"-DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF"
			"-DLIBCXX_HAS_RT_LIB=NO"
			"-DLIBCXX_ENABLE_INCOMPLETE_FEATURES=OFF"
			"-DLLVM_ENABLE_LTO=Full"
		)
	fi

	# b/205342596: This is a hack to provide armv6m libraries for use with
	# arm-none-eabi without creating a separate armv6m toolchain.
	# shellcheck disable=SC2154 # CTARGET is assigned elsewhere.
	if [[ "${CTARGET}" == arm-none-eabi ]]; then
		append-flags "-march=armv6m --sysroot=/usr/arm-none-eabi"
		mycmakeargs+=(
			"-DCMAKE_C_COMPILER_TARGET=armv6m-none-eabi"
			"-DCMAKE_CXX_COMPILER_TARGET=armv6m-none-eabi"
		)
	elif [[ "${CTARGET}" == armv7m-cros-eabi ]]; then
		# b/286910996: Set target-specific floating point flags.
		append-flags -mcpu=cortex-m4
		append-flags -mfloat-abi=hard
	fi
	cmake_src_configure
}

# Usage: deps
gen_ldscript() {
	local output_format
	# shellcheck disable=SC2086
	output_format=$($(tc-getCC) ${CFLAGS} ${LDFLAGS} -Wl,--verbose 2>&1 | sed -n 's/^OUTPUT_FORMAT("\([^"]*\)",.*/\1/p')
	[[ -n ${output_format} ]] && output_format="OUTPUT_FORMAT ( ${output_format} )"

	cat <<-END_LDSCRIPT
/* GNU ld script
	Include missing dependencies
*/
${output_format}
GROUP ( $@ )
END_LDSCRIPT
}

gen_static_ldscript() {
	local libdir=$(get_libdir)
	local cxxabi_lib=$(usex libcxxabi "libc++abi.a" "$(usex libcxxrt "libcxxrt.a" "libsupc++.a")")

	# Move it first.
	mv "${ED}/${PREFIX}/${libdir}/libc++.a" "${ED}/${PREFIX}/${libdir}/libc++_static.a" || die
	# Generate libc++.a ldscript for inclusion of its dependencies so that
	# clang++ -stdlib=libc++ -static works out of the box.
	local deps="libc++_static.a ${cxxabi_lib} $(usex libunwind libunwind.a libgcc_eh.a)"
	# On Linux/glibc it does not link without libpthread or libdl. It is
	# fine on FreeBSD.
	use elibc_glibc && ! is_baremetal_abi && deps+=" libpthread.a libdl.a"

	gen_ldscript "${deps}" > "${ED}/${PREFIX}/${libdir}/libc++.a" || die
}

gen_shared_ldscript() {
	local libdir=$(get_libdir)
	# libsupc++ doesn't have a shared version
	local cxxabi_lib=$(usex libcxxabi "libc++abi.so" "$(usex libcxxrt "libcxxrt.so" "libsupc++.a")")
	mv "${ED}/${PREFIX}/${libdir}/libc++.so" "${ED}/${PREFIX}/${libdir}/libc++_shared.so" || die
	local deps="libc++_shared.so ${cxxabi_lib} $(usex compiler-rt '' $(usex libunwind libunwind.so libgcc_s.so))"

	gen_ldscript "${deps}" > "${ED}/${PREFIX}/${libdir}/libc++.so" || die
}

multilib_src_install() {
	cmake_src_install
	is_baremetal_abi || gen_shared_ldscript
	use static-libs && gen_static_ldscript
}

multilib_src_install_all() {
	if [[ ${CATEGORY} == cross-* ]]; then
		rm -r "${ED}/usr/share/doc"
		if is_baremetal_abi; then
			# Override libc++ abort to do nothing for baremetal as it increases
			# flash size (b/277967012).
			sed -i '/#define\ _LIBCPP___CONFIG_SITE/a #define\ _LIBCPP_VERBOSE_ABORT\(\.\.\.\)' \
				"${ED}/${PREFIX}/include/c++/v1/__config_site" || die
		fi
	fi
}
