# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

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

inherit eutils toolchain-funcs cros-constants cmake git-2 cros-llvm cros-workon python-single-r1

EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project
	${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project"
EGIT_BRANCH=main

# LLVM_HASH is no longer used by this ebuild, but is necessary
# still while we update the toolchain-utils scripts to support
# its abscence. The new LLVM_HASH is stored in the _toolchain.xml
# manifest file.
# shellcheck disable=SC2034
LLVM_HASH="14f0776550b5a49e1c42f49a00213f7f3fa047bf" # r498229
LLVM_NEXT_HASH="82e851a407c52d65ce65e7aa58453127e67d42a0" # r510928

DESCRIPTION="Compiler runtime library for clang"
HOMEPAGE="http://compiler-rt.llvm.org/"

LICENSE="LLVM-exception"
SLOT="0"
KEYWORDS="~*"
IUSE="+llvm-crt continue-on-patch-failure"
if [[ "${PV}" != "9999" ]]; then
	IUSE+=" llvm-next"
fi

BDEPEND="
	sys-devel/llvm
	${PYTHON_DEPS}
"

if [[ ${CATEGORY} == cross-* ]] ; then
	BDEPEND+="
		${CATEGORY}/binutils
		"
fi
if [[ ${CATEGORY} == cross-*linux-gnu* ]] ; then
	DEPEND+="
		${CATEGORY}/libxcrypt
		${CATEGORY}/linux-headers
	"
fi

pkg_setup() {
	# Since compiler-rt is moving to runtimes,
	# we should build with CMAKE there.
	export CMAKE_USE_DIR="${S}/runtimes"
}

src_unpack() {
	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next; then
			# According to cros-workon, CROS_WORKON_COMMIT cannot be
			# enabled in a 9999 ebuild. We also want to override it
			# when we're using llvm-next or llvm-tot. We need to
			# specify that this doesn't get removed by portage_util.
			CROS_WORKON_COMMIT=("${LLVM_NEXT_HASH}")  # portage_util: no edit
			CROS_WORKON_TREE=()  # portage_util: no edit
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
		most_recent_revision="$(<"${T}/llvm-rev")"
	else
		most_recent_revision="$(get_most_recent_revision)"
	fi
	"${FILESDIR}"/patch_manager/patch_manager.py \
		--svn_version "${most_recent_revision}" \
		--patch_metadata_file "${FILESDIR}"/PATCHES.json \
		--failure_mode "${failure_mode}" \
		--src_path "${S}" || die

	cmake_src_prepare
}

src_configure() {
	setup_cross_toolchain
	append-flags "-fomit-frame-pointer"
	# CTARGET is defined in an eclass, which shellcheck won't see
	# shellcheck disable=SC2154
	if [[ ${CTARGET} == armv7a* ]]; then
		# Use vfpv3 to be able to target non-neon targets
		append-flags -mfpu=vfpv3
	fi
	BUILD_DIR=${WORKDIR}/${P}_build

	local mycmakeargs=(
		"-DLLVM_ENABLE_RUNTIMES=compiler-rt"
		"-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
		# crbug/855759
		"-DCOMPILER_RT_BUILD_CRT=$(usex llvm-crt)"
		"-DCOMPILER_RT_USE_LIBCXX=yes"
		"-DCOMPILER_RT_LIBCXXABI_PATH=${S}/libcxxabi"
		"-DCOMPILER_RT_LIBCXX_PATH=${S}/libcxx"
		"-DCOMPILER_RT_HAS_GNU_VERSION_SCRIPT_COMPAT=no"
		"-DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF"
		"-DCOMPILER_RT_SANITIZERS_TO_BUILD=asan;msan;hwasan;tsan;cfi;ubsan_minimal;gwp_asan"
		# b/200831212: Disable per runtime install dirs.
		"-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF"
		# b/204220308: Disable ORC since we are not using it.
		"-DCOMPILER_RT_BUILD_ORC=OFF"
		"-DCOMPILER_RT_INSTALL_PATH=${EPREFIX}$(${CC} --print-resource-dir)"
	)

	if is_baremetal_abi; then
		# Options for baremetal toolchains e.g. armv7m-cros-eabi.
		append-flags -Oz # Optimize for smallest size.

		mycmakeargs+=(
			"-DCMAKE_POSITION_INDEPENDENT_CODE=OFF"
			"-DCOMPILER_RT_BUILTINS_ENABLE_PIC=OFF"
			"-DCOMPILER_RT_OS_DIR=baremetal"
			"-DCOMPILER_RT_BAREMETAL_BUILD=yes"
			"-DCMAKE_C_COMPILER_TARGET=${CTARGET}"
			"-DCOMPILER_RT_DEFAULT_TARGET_ONLY=yes"
			"-DCOMPILER_RT_BUILD_CRT=OFF"
			"-DCOMPILER_RT_BUILD_SANITIZERS=no"
			"-DCOMPILER_RT_BUILD_LIBFUZZER=no"
		)
		# b/205342596: This is a hack to provide armv6m builtins for use with
		# arm-none-eabi without creating a separate armv6m toolchain.
		if [[ ${CTARGET} == arm-none-eabi ]]; then
			append-flags "-march=armv6m --sysroot=/usr/arm-none-eabi"
			mycmakeargs+=( "-DCMAKE_C_COMPILER_TARGET=armv6m-none-eabi" )
		elif [[ "${CTARGET}" == armv7m-cros-eabi ]]; then
			# b/286910996: Set target-specific floating point flags.
			append-flags -mcpu=cortex-m4
			append-flags -mfloat-abi=hard
		fi
	else
		# Standard userspace toolchains e.g. armv7a-cros-linux-gnueabihf.
		mycmakeargs+=(
			"-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=${CTARGET}"
			"-DCOMPILER_RT_TEST_TARGET_TRIPLE=${CTARGET}"
			"-DCOMPILER_RT_BUILD_LIBFUZZER=yes"
			"-DCOMPILER_RT_BUILD_SANITIZERS=yes"
		)
	fi
	cmake_src_configure
}

src_install() {
	# There is install conflict between cross-armv7a-cros-linux-gnueabihf
	# and cross-armv7a-cros-linux-gnueabi. Remove this once we are ready to
	# move to cross-armv7a-cros-linux-gnueabihf.
	if [[ ${CTARGET} == armv7a-cros-linux-gnueabi ]] ; then
		return
	fi
	cmake_src_install

	# includes and docs are installed for all sanitizers and xray
	# These files conflict with files provided in llvm ebuild
	local libdir=$(llvm-config --libdir)
	rm -rf "${ED}"/usr/share || die
	rm -rf "${ED}${libdir}"/clang/*/include || die
	rm -f "${ED}${libdir}"/clang/*/*list.txt || die
	rm -f "${ED}${libdir}"/clang/*/*/*list.txt || die
	rm -f "${ED}${libdir}"/clang/*/dfsan_abilist.txt || die
	rm -f "${ED}${libdir}"/clang/*/*/dfsan_abilist.txt || die
	rm -f "${ED}${libdir}"/clang/*/bin/* || die

	if is_baremetal_abi; then
		# Verify that no relocations are generated for baremetal.
		local elf_file had_failures=false
		while read -r elf_file; do
			if $(tc-getREADELF) --relocs "${elf_file}" | grep GOT; then
				eerror "Unexpected GOT relocations found in ${elf_file}"
				had_failures=true
			fi
		done < <(scanelf -RByF '%F' "${D}")
		"${had_failures}" && die "GOT relocations found in baremetal"
	fi

	# Copy compiler-rt files to a new clang version to handle llvm updates gracefully.
	local llvm_version=$(llvm-config --version)
	local clang_full_version=${llvm_version%svn*}
	clang_full_version=${clang_full_version%git*}
	local major_version=${clang_full_version%%.*}
	local new_full_version="$((major_version + 1)).0.0"
	local old_full_version="$((major_version - 1)).0.0"
	local new_major_version="$((major_version + 1))"
	local old_major_version="$((major_version - 1))"
	# Upstream has moved to use major version instead of major.minor.sub format.
	# So copy installed files to both (major+/-1) and (major+/-1).0.0 dirs.
	local rt_install_path
	if [[ -d "${D}${libdir}/clang/${clang_full_version}" ]]; then
		rt_install_path="${D}${libdir}/clang/${clang_full_version}"
		# Copy files from /path/<num>.0.0 to /path/<num>.
		cp -r "${rt_install_path}" "${D}${libdir}/clang/${major_version}" || die
	elif [[ -d "${D}${libdir}/clang/${major_version}" ]]; then
		rt_install_path="${D}${libdir}/clang/${major_version}"
		# Copy files from /path/<num> to /path/<num>.0.0 .
		cp -r "${rt_install_path}" "${D}${libdir}/clang/${clang_full_version}" || die
	else
		die "Could not find installed compiler-rt files."
	fi
	cp -r "${rt_install_path}" "${D}${libdir}/clang/${new_full_version}" || die
	cp -r "${rt_install_path}" "${D}${libdir}/clang/${new_major_version}" || die
	cp -r "${rt_install_path}" "${D}${libdir}/clang/${old_full_version}" || die
	cp -r "${rt_install_path}" "${D}${libdir}/clang/${old_major_version}" || die
}
