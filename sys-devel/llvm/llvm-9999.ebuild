# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

inherit cros-constants

CROS_WORKON_REPO="${CROS_GIT_HOST_URL}"
CROS_WORKON_PROJECT="external/github.com/llvm/llvm-project"
CROS_WORKON_LOCALNAME="llvm-project"
CROS_WORKON_EGIT_BRANCH="main"

# When building the 9999 ebuild, cros-workon will `rsync --exclude=.git` the
# project, so we don't have access to the git repository. When building a
# versioned ebuild, cros-workon will create a shallow clone that has a .git
# directory. So we need to use the PRECLONE_HOOK in the 9999 case to calculate
# the SVN revision.
if [[ "${PV}" == "9999" ]]; then
	# shellcheck disable=SC2034
	CROS_WORKON_PRECLONE_HOOK="cros-llvm_default_preclone_hook"
fi

inherit cros-workon cmake flag-o-matic git-r3 multilib-minimal  \
	python-single-r1 pax-utils toolchain-funcs cros-llvm


LLVM_HASH="14f0776550b5a49e1c42f49a00213f7f3fa047bf" # r498229
LLVM_NEXT_HASH="82e851a407c52d65ce65e7aa58453127e67d42a0" # r510928

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="http://llvm.org/"

# llvm-9999's sources can vary a lot, so don't allow PGO there.
if [[ "${PV}" != "9999" ]]; then
	SRC_URI="
		!llvm-next? ( llvm_pgo_use? ( gs://chromeos-localmirror/distfiles/llvm-profdata-${LLVM_HASH}.tar.xz ) )
	"
fi

# See go/rex-vulkan-ray-tracing for information about SPIR-V support
SPIRV_LLVM_TRANSLATOR_VERSION="a4cdee9091ee94a87096c27511d3922061f1f170"
SPIRV_LLVM_NEXT_TRANSLATOR_VERSION="e68ddf71512a77a6bae4b281578d52e0ab98ab2f"
SPIRV_HEADERS_VERSION="1.3.261.0"
SRC_URI+="
	spirv-translator? (
		!llvm-next? (
			https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/${SPIRV_LLVM_TRANSLATOR_VERSION}.tar.gz -> SPIRV-LLVM-Translator-${SPIRV_LLVM_TRANSLATOR_VERSION}.tar.gz
		)
		llvm-next? (
			https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/${SPIRV_LLVM_NEXT_TRANSLATOR_VERSION}.tar.gz -> SPIRV-LLVM-Translator-${SPIRV_LLVM_NEXT_TRANSLATOR_VERSION}.tar.gz
		)
		https://github.com/KhronosGroup/SPIRV-Headers/archive/sdk-${SPIRV_HEADERS_VERSION}.tar.gz -> spirv-headers-${SPIRV_HEADERS_VERSION}.tar.gz
	)
"

LICENSE="LLVM-exception"
SLOT="8"
KEYWORDS="-* ~amd64"
IUSE="debug +default-compiler-rt +default-libcxx doc +libedit llvm-asserts
	+llvm-crt llvm-next llvm_pgo_generate +llvm_pgo_use llvm_pgo_use_local
	multitarget ncurses ocaml spirv-translator test +thinlto
	video_cards_radeon continue-on-patch-failure +wrapper_ccache"

COMMON_DEPEND="
	app-arch/xz-utils:0=[${MULTILIB_USEDEP}]
	app-arch/zstd:0=[${MULTILIB_USEDEP}]
	dev-libs/libxml2:2=[${MULTILIB_USEDEP}]
	sys-libs/binutils-libs:0=[${MULTILIB_USEDEP}]
	sys-libs/libxcrypt:0=[${MULTILIB_USEDEP}]
	sys-libs/zlib:0=[${MULTILIB_USEDEP}]
	libedit? ( dev-libs/libedit:0=[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.9-r3:0=[${MULTILIB_USEDEP}] )
	ocaml? (
		>=dev-lang/ocaml-4.00.0:0=
		dev-ml/findlib
		dev-ml/ocaml-ctypes )
	spirv-translator? ( dev-util/spirv-tools )"
# configparser-3.2 breaks the build (3.3 or none at all are fine)
DEPEND="${COMMON_DEPEND}
	sys-devel/binutils
	ocaml? ( test? ( dev-ml/ounit ) )"
RDEPEND="${COMMON_DEPEND}
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-baselibs-20130224-r2
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )
	${PYTHON_DEPS}
	!<=sys-devel/llvm-8.0_pre
	!sys-devel/lld
	!sys-devel/clang"
BDEPEND="
	dev-lang/go
	dev-lang/perl
	sys-devel/gnuconfig
	${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/dataclasses[${PYTHON_USEDEP}]' python3_6)
	$(python_gen_cond_dep '
		dev-python/sphinx[${PYTHON_USEDEP}]
		doc? ( dev-python/recommonmark[${PYTHON_USEDEP}] )
	')
"

# pypy gives me around 1700 unresolved tests due to open file limit
# being exceeded. probably GC does not close them fast enough.
REQUIRED_USE="
	llvm_pgo_generate? ( !llvm_pgo_use !llvm_pgo_use_local )
	llvm_pgo_use? ( !llvm_pgo_use_local )
"

apply_pgo_profile() {
	[[ "${PV}" != "9999" ]] && use llvm_pgo_use && ! use llvm-next
}

src_unpack() {
	export CMAKE_USE_DIR="${S}/llvm"

	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next; then
			CROS_WORKON_COMMIT=("${LLVM_NEXT_HASH}") # portage_util: no edit
			CROS_WORKON_TREE=() # portage_util: no edit
		fi
	fi
	cros-workon_src_unpack

	if apply_pgo_profile; then
		cd "${WORKDIR}" || die
		unpack "llvm-profdata-${LLVM_HASH}.tar.xz"
	fi

	if use spirv-translator; then
		pushd "${S}/llvm/projects/" >/dev/null || die

		local ver="${SPIRV_LLVM_TRANSLATOR_VERSION}"
		use llvm-next && ver="${SPIRV_LLVM_NEXT_TRANSLATOR_VERSION}"

		unpack "SPIRV-LLVM-Translator-${ver}.tar.gz"
		mv SPIRV-LLVM-Translator{-${ver},} || die

		unpack "spirv-headers-${SPIRV_HEADERS_VERSION}.tar.gz"
		mv SPIRV-Headers{-sdk-${SPIRV_HEADERS_VERSION},} || die

		popd >/dev/null || die
	fi
}

src_prepare() {
	# Make ocaml warnings non-fatal, bug #537308
	sed -e "/RUN/s/-warn-error A//" -i llvm/test/Bindings/OCaml/*ml  || die

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

	cmake_src_prepare

	# Native libdir is used to hold LLVMgold.so
	# shellcheck disable=SC2034
	NATIVE_LIBDIR=$(get_libdir)
}

multilib_src_configure() {
	export CMAKE_BUILD_TYPE="RelWithDebInfo"

	append-flags -Wno-poison-system-directories

	local targets
	if use multitarget; then
	# for LLVM breakages specific to BPF (only)
	# contact cros-enterprise-security@google.com
	# for everything else contact OWNERs
		targets='host;X86;ARM;AArch64;NVPTX;BPF'
	else
		targets='host;CppBackend'
		use video_cards_radeon && targets+=';AMDGPU'
	fi

	local enable_asserts=no
	if use debug || use llvm-asserts; then
		enable_asserts=yes
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_ENABLE_PROJECTS=llvm;clang;lld;lldb;compiler-rt;clang-tools-extra"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"

		"-DLLVM_BUILD_LLVM_DYLIB=ON"
		# Link LLVM statically
		"-DLLVM_LINK_LLVM_DYLIB=OFF"
		"-DBUILD_SHARED_LIBS=OFF"

		"-DLLVM_TARGETS_TO_BUILD=${targets}"

		"-DLLVM_INCLUDE_BENCHMARKS=$(usex test)"
		"-DLLVM_INCLUDE_EXAMPLES=$(usex test)"
		"-DLLVM_INCLUDE_TESTS=$(usex test)"
		"-DLLVM_BUILD_TESTS=$(usex test)"

		"-DLLVM_ENABLE_FFI=NO"
		"-DLLVM_ENABLE_TERMINFO=$(usex ncurses)"
		"-DLLVM_ENABLE_ASSERTIONS=${enable_asserts}"
		"-DLLVM_ENABLE_EH=ON"
		"-DLLVM_ENABLE_RTTI=ON"
		# libxml is only used for llvm-mt, which is a Windows-specific tool.
		"-DLLVM_ENABLE_LIBXML2=OFF"

		"-DWITH_POLLY=OFF" # TODO

		"-DLLVM_HOST_TRIPLE=${CHOST}"

		"-DLLVM_BINUTILS_INCDIR=${SYSROOT}/usr/include"

		"-DHAVE_HISTEDIT_H=$(usex libedit)"
		"-DENABLE_LINKER_BUILD_ID=ON"
		"-DCLANG_VENDOR=Chromium OS ${PVR}"
		# override default stdlib and rtlib
		"-DCLANG_DEFAULT_CXX_STDLIB=$(usex default-libcxx libc++ "")"
		"-DCLANG_DEFAULT_RTLIB=$(usex default-compiler-rt compiler-rt "")"

		# Link against libcxx
		"-DLLVM_ENABLE_LIBCXX=Yes"
		# Use lld to link llvm
		"-DLLVM_USE_LINKER=lld"

		# crbug/855759
		"-DCOMPILER_RT_BUILD_CRT=$(usex llvm-crt)"

		"-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
		"-DCLANG_DEFAULT_UNWINDLIB=libgcc"
		"-DCLANG_DEFAULT_PIE_ON_LINUX=ON"

		# workaround for crbug/1198796
		"-DCLANG_TOOLING_BUILD_AST_INTROSPECTION=OFF"
		# No one uses plugins; turning them off makes LLVM marginally
		# smaller & faster.
		"-DCLANG_PLUGIN_SUPPORT=OFF"

		# By default do not enable PGO for compiler-rt
		"-DCOMPILER_RT_ENABLE_PGO=OFF"

		# compiler-rt needs libc++ sources to be specified to build
		# an internal copy for libfuzzer, can be removed if libc++
		# is built inside llvm ebuild.
		"-DCOMPILER_RT_LIBCXXABI_PATH=${S}/libcxxabi"
		"-DCOMPILER_RT_LIBCXX_PATH=${S}/libcxx"
		"-DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF"

		# b/200831212: Disable per runtime install dirs.
		"-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF"

		# b/202073091: Disable Lua.
		"-DLLDB_ENABLE_LUA=OFF"

		# b/204220308: Disable ORC since we are not using it.
		"-DCOMPILER_RT_BUILD_ORC=OFF"

		# b/241569725: Explicitly set Python version so that it
		# chooses the version we're currently supporting
		"-DPython3_EXECUTABLE=${PYTHON}"
	)

	# The standalone toolchain may be run at places not supporting smallPIE,
	# disabling it for lld.
	# Pass -fuse-ld=lld to make cmake happy.
	append-ldflags "-fuse-ld=lld -Wl,--pack-dyn-relocs=none"

	if use thinlto; then
		mycmakeargs+=(
			"-DLLVM_ENABLE_LTO=thin"
			# b/228090090: LLVM defaults to 2 parallel link
			# jobs with ThinLTO enabled. Bumping this to 4
			# speeds `emerge llvm` up on dev machines by
			# 1.25x, and saves >10mins per LLVM build on the
			# SDK builder.
			"-DLLVM_PARALLEL_LINK_JOBS=4"
			# b/298428344: Disable ThinLTO's cache, as it makes our
			# LLVM builds nondeterministic. The observed
			# nondeterminism is functionally irrelevant (literally
			# just an extra symbol in .symtab), but the bazel effort
			# seeks bit determinism.
			"-DLLVM_THINLTO_CACHE_PATH="
		)
		# b/227370760: Instr limits above 30 don't seem to help
		# our performance (and might hurt in some cases). They
		# also make builds take meaningfully longer, and add
		# tens of MB to our SDK size. We tune this back in other
		# large ThinLTO users (e.g., Chrome), so do it here,
		# too.
		append-ldflags "-Wl,-mllvm,-import-instr-limit=30"
	fi

	local pgo_profile
	if apply_pgo_profile; then
		pgo_profile="${WORKDIR}/llvm.profdata"
	elif use llvm_pgo_use_local; then
		pgo_profile="-DLLVM_PROFDATA_FILE=${FILESDIR}/llvm-local.profdata"
	elif use llvm_pgo_generate; then
		# Our benchmarks run out of static counters; allow them
		# to be dynamically allocated (which adds overhead, but
		# increases precision).
		append-flags -mllvm -vp-static-alloc=false
		mycmakeargs+=(
			"-DLLVM_BUILD_INSTRUMENTED=IR"
		)
	fi

	if [[ -n "${pgo_profile}" ]]; then
		mycmakeargs+=(
			"-DLLVM_PROFDATA_FILE=${pgo_profile}"
		)

		# Disable warning about profile not matching. These are emitted
		# when PGO profiles don't apply to functions, and are a signal
		# of code 'drifting' & the PGO profile degrading. Some
		# degredation is expected as a normal part of patching LLVM.
		append-flags "-Wno-backend-plugin"
	fi

	if ! multilib_is_native_abi || ! use ocaml; then
		mycmakeargs+=(
			"-DOCAMLFIND=NO"
		)
	fi

	if [[ -z "${CCACHE_DISABLE:-}" ]]; then
		# If ccache is enabled, use it as a compiler launcher. Chances
		# are that folks are iterating on LLVM, and ccache speeds that
		# up substantially.
		mycmakeargs+=(
			"-DCMAKE_C_COMPILER_LAUNCHER=ccache"
			"-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
		)
	fi

	if multilib_is_native_abi; then
		mycmakeargs+=(
			"-DLLVM_BUILD_DOCS=$(usex doc)"
			"-DLLVM_ENABLE_SPHINX=$(usex doc)"
			"-DLLVM_ENABLE_DOXYGEN=OFF"
			"-DLLVM_INSTALL_HTML=${EPREFIX}/usr/share/doc/${PF}/html"
			"-DSPHINX_WARNINGS_AS_ERRORS=OFF"
			"-DLLVM_INSTALL_UTILS=ON"
		)
	fi

	if [[ "${enable_asserts}" == no ]]; then
		append-cppflags -DNDEBUG
	fi

	cmake_src_configure
}

multilib_src_compile() {
	# ...If folks are iterating on LLVM with `emerge`, every successful
	# `emerge` invocation will replace their old compiler. Since doing so
	# updates mtimes, we should be focusing on the _content_ of the
	# compiler, rather than the mtime.
	#
	# Note that this is in `src_compile`, since it won't apply if we do it
	# in `src_configure`.
	export CCACHE_COMPILERCHECK=content
	cmake_src_compile

	pax-mark m "${BUILD_DIR}"/bin/llvm-rtdyld
	pax-mark m "${BUILD_DIR}"/bin/lli
	pax-mark m "${BUILD_DIR}"/bin/lli-child-target

	if use test; then
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/Orc/OrcJITTests
		pax-mark m "${BUILD_DIR}"/unittests/ExecutionEngine/MCJIT/MCJITTests
		pax-mark m "${BUILD_DIR}"/unittests/Support/SupportTests
	fi
}

multilib_src_test() {
	# respect TMPDIR!
	local -x LIT_PRESERVES_TMP=1
	cmake_src_test
}

src_install() {
	local MULTILIB_CHOST_TOOLS=(
		/usr/bin/llvm-config
	)

	local MULTILIB_WRAPPED_HEADERS=(
		/usr/include/llvm/Config/config.h
		/usr/include/llvm/Config/llvm-config.h
	)

	multilib-minimal_src_install
}

# This computes the toolchain SHA that gets baked into our compiler_wrapper
# binaries. This SHA is potentially nice for uniquely identifying a toolchain,
# but the most critical purpose that it serves is making the SHA for our
# compiler_wrapper change with the toolchain that it was installed with. If any
# of these binaries get modified and we fail to update compiler_wrapper, tools
# like ccache, ninja, etc might not expect the updates without extra work (thus,
# cached object files might not be considered stale across compiler updates).
#
# Rather than playing whack-a-mole with ways to inform each build system that
# our compiler has changed (despite its hash remaining identical), we simply
# modify its hash when any of the binaries it calls may change.
compute_toolchain_sha() {
	local toolchain_sha_binaries=(
		"bin/clang"
		"bin/clang-tidy"
		"bin/ld.lld"
	)

	# Compute the SHA sums for each of these in parallel, then hash the
	# result. This hash represents all of the (non-header, non-library)
	# dependencies that Clang has.
	#
	# This is expected to be called in a subshell, so don't try to restore
	# pipefail.
	set -o pipefail
	echo "${toolchain_sha_binaries[*]}" |
		xargs -L1 -P8 sha256sum |
		sort -k2 |
		sha256sum - |
		awk '{print $1}'
}

multilib_src_install() {
	cmake_src_install

	local use_llvm_next=false
	use llvm-next && use_llvm_next=true
	local wrapper_script=clang_host_wrapper

	local toolchain_sha
	echo "Current directory is $(pwd)"
	toolchain_sha="$(compute_toolchain_sha)" || die
	einfo "Computed toolchain SHA = ${toolchain_sha}"

	local common_wrapper_flags=(
		"--version=toolchain_sha_${toolchain_sha}"
	)

	GO111MODULE=off "${FILESDIR}/compiler_wrapper/build.py" --config=cros.host --use_ccache=false \
		--use_llvm_next="${use_llvm_next}" \
		--output_file="${D}/usr/bin/${wrapper_script}" \
		"${common_wrapper_flags[@]}" || die

	newbin "${D}/usr/bin/clang-tidy" "clang-tidy"
	dobin "${FILESDIR}/bisect_driver.py"
	dobin "${FILESDIR}/clang_cc_wrapper"
	exeinto "/usr/bin"
	dosym "${wrapper_script}" "/usr/bin/${CHOST}-clang"
	dosym "${wrapper_script}" "/usr/bin/${CHOST}-clang++"
	newexe "${FILESDIR}/ldwrapper_lld.host" "${CHOST}-ld.lld"

	# llvm-strip is a symlink to llvm-objcopy and distinguished by a argv[0] check.
	# When creating standalone toolchain, argv[0] information is lost and causes
	# llvm-strip invocations to be treated as llvm-objcopy breaking builds
	# (crbug.com/1151787). Handle this by making llvm-strip a full binary.
	if [[ -L "${D}/usr/bin/llvm-strip" ]]; then
		rm "${D}/usr/bin/llvm-strip" || die
		newbin "${D}/usr/bin/llvm-objcopy" "llvm-strip"
	fi

	# Build and install cross-compiler wrappers for supported ABIs.
	# ccache wrapper is used in chroot and non-ccache wrapper is used
	# in standalone SDK.
	local ccache_suffixes=(noccache ccache)
	local ccache_option_values=(false true)
	for ccache_index in {0,1}; do
		local ccache_suffix="${ccache_suffixes[${ccache_index}]}"
		local ccache_option="${ccache_option_values[${ccache_index}]}"
		# Build hardened wrapper written in golang.
		GO111MODULE=off "${FILESDIR}/compiler_wrapper/build.py" --config="cros.hardened" \
			--use_ccache="${ccache_option}" \
			--use_llvm_next="${use_llvm_next}" \
			--output_file="${D}/usr/bin/sysroot_wrapper.hardened.${ccache_suffix}" \
			"${common_wrapper_flags[@]}" || die

		# Build non-hardened wrapper written in golang.
		GO111MODULE=off "${FILESDIR}/compiler_wrapper/build.py" --config="cros.nonhardened" \
			--use_ccache="${ccache_option}" \
			--use_llvm_next="${use_llvm_next}" \
			--output_file="${D}/usr/bin/sysroot_wrapper.${ccache_suffix}" \
			"${common_wrapper_flags[@]}" || die
	done

	local cros_hardened_targets=(
		# TODO(b/266132652): Add new llvm-libc baremetal targets
		"aarch64-cros-linux-gnu"
		"armv7a-cros-linux-gnueabihf"
		"i686-cros-linux-gnu"
		"x86_64-cros-linux-gnu"
	)
	local cros_nonhardened_targets=(
		"arm-none-eabi"
		"armv7m-cros-eabi"
	)

	local use_ccache_index
	use_ccache_index="$(usex wrapper_ccache 1 0)"
	local sysroot_wrapper_suffix="${ccache_suffixes[${use_ccache_index}]}"

	local target
	for target in "${cros_hardened_targets[@]}"; do
		dosym "sysroot_wrapper.hardened.${sysroot_wrapper_suffix}" "/usr/bin/${target}-clang"
		dosym "sysroot_wrapper.hardened.${sysroot_wrapper_suffix}" "/usr/bin/${target}-clang++"
	done
	for target in "${cros_nonhardened_targets[@]}"; do
		dosym "sysroot_wrapper.${sysroot_wrapper_suffix}" "/usr/bin/${target}-clang"
		dosym "sysroot_wrapper.${sysroot_wrapper_suffix}" "/usr/bin/${target}-clang++"
	done

	# Install a symlink bpf-clang which point to clang.
	# Running through symlink will make clang default to bpf target.
	dosym "clang" "/usr/bin/bpf-clang"

	# Remove this file, if it exists, to avoid installation file collision,
	# as this file is also generated/installed by the dev-python/six package.
	find "${D}"/usr -name 'six.py' -delete
}

multilib_src_install_all() {
	insinto /usr/share/vim/vimfiles
	doins -r llvm/utils/vim/*/.
	# some users may find it useful
	dodoc llvm/utils/vim/vimrc
	dobin "${S}/compiler-rt/lib/asan/scripts/asan_symbolize.py"
}

pkg_postinst() {
	if has_version ">=dev-util/ccache-3.1.9-r2" ; then
		#add ccache links as clang might get installed after ccache
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi
}

pkg_postrm() {
	if has_version ">=dev-util/ccache-3.1.9-r2" && [[ -z ${REPLACED_BY_VERSION} ]]; then
		# --remove-links would remove all links, --install-links updates them
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi
}
