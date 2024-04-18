# Copyright 2021 Gentoo Foundation
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

inherit cros-constants cmake-multilib git-2 flag-o-matic cros-llvm python-single-r1 toolchain-funcs cros-workon

DESCRIPTION="lldb-server, for the LLDB debugger"
HOMEPAGE="https://github.com/llvm/llvm-project"
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
IUSE="cros_host continue-on-patch-failure python"
if [[ "${PV}" != "9999" ]]; then
	IUSE+=" llvm-next"
fi
RDEPEND="
	app-arch/xz-utils
	app-arch/zstd
	python? (
		$(python_gen_cond_dep '
			dev-python/six[${PYTHON_USEDEP}]
		')
		${PYTHON_DEPS}
	)
"

DEPEND="${RDEPEND}
	sys-libs/ncurses"

BDEPEND="
	${PYTHON_DEPS}
	>=dev-util/cmake-3.16
	python? (
		>=dev-lang/swig-3.0.11
		$(python_gen_cond_dep '
			dev-python/six[${PYTHON_USEDEP}]
		')
	)
"

pkg_setup() {
	use cros_host && die "lldb is not supported for building on non-device builds"
	python-single-r1_pkg_setup
	# Setup llvm toolchain for cross-compilation.
	setup_cross_toolchain
	export CMAKE_USE_DIR="${S}/lldb"
}

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
	cmake_src_prepare
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
}

build_llvm_host() {
	echo "Building host llvm tools"
	mkdir llvm_build_host
	pushd llvm_build_host || die
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_ENABLE_PROJECTS=llvm;clang;lldb"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"
		"-DCMAKE_BUILD_TYPE=RelWithDebInfo"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
		"-DLLVM_TARGETS_TO_BUILD=X86"
		"-DLLVM_BUILD_TOOLS=OFF"
		"-DLLVM_BUILD_TESTS=OFF"
		"-DLLVM_INCLUDE_TESTS=OFF"
		"-DLLVM_INCLUDE_DOCS=OFF"
		"-DLLVM_INCLUDE_UTILS=OFF"
		"-DLLVM_BUILD_UTILS=OFF"
		"-DLLVM_USE_HOST_TOOLS=OFF"
		"-DLLVM_ENABLE_ZLIB=OFF"
		"-DLLVM_BUILD_TESTS=OFF"
		"-DLLVM_INCLUDE_TESTS=OFF"
		"-DLLVM_INCLUDE_DOCS=OFF"
		"-DLLVM_INCLUDE_UTILS=OFF"
		"-DLLVM_BUILD_UTILS=OFF"
		"-DLLVM_USE_HOST_TOOLS=OFF"
		"-DLLVM_ENABLE_ZLIB=OFF"
		"-DCLANG_BUILD_TOOLS=OFF"
		"-DCLANG_ENABLE_ARCMT=OFF"
		"-DCLANG_ENABLE_STATIC_ANALYZER=OFF"
		"-DCLANG_INCLUDE_TESTS=OFF"
		"-DCLANG_INCLUDE_DOCS=OFF"
		"-DLLVM_ENABLE_IDE=ON"
		"-DLLVM_ENABLE_ZSTD=OFF"
		"-DLLVM_ADD_NATIVE_VISUALIZERS_TO_SOLUTION=OFF"
		"-DCLANG_LINK_CLANG_DYLIB=OFF"
		"-DLLVM_BUILD_LLVM_DYLIB=OFF"
		"-DLLVM_LINK_LLVM_DYLIB=OFF"
		"-DLLVM_INCLUDE_EXAMPLES=OFF"
		"-DLLVM_INCLUDE_RUNTIMES=OFF"
		"-DLLVM_INCLUDE_BENCHMARKS=OFF"
		"-DLLDB_ENABLE_PYTHON=OFF"
		"-DLLDB_ENABLE_LIBEDIT=OFF"
		"-DLLDB_ENABLE_CURSES=OFF"
		"-DPython3_EXECUTABLE=${PYTHON}"
	)
	tc-env_build cmake -GNinja "${mycmakeargs[@]}" "${S}/llvm" || die
	ninja llvm-tblgen clang-tblgen lldb-tblgen || die
	popd || die
}

build_llvm_libs() {
	echo "Cross-compiling llvm and clang libraries"
	mkdir llvm_build
	pushd llvm_build || die
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_ENABLE_PROJECTS=llvm;clang"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"
		"-DLLVM_TARGETS_TO_BUILD=X86;ARM;AArch64"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
		"-DCMAKE_CROSSCOMPILING=ON"
		"-DCMAKE_BUILD_TYPE=RelWithDebInfo"
		"-DLLVM_BUILD_TOOLS=OFF"
		"-DLLDB_EXTERNAL_CLANG_RESOURCE_DIR=$(tc-getCC --print-resource-dir)"
		"-DLLDB_INCLUDE_TESTS=OFF"
		"-DLLVM_TABLEGEN=../llvm_build_host/bin/llvm-tblgen"
		"-DCLANG_TABLEGEN=../llvm_build_host/bin/clang-tblgen"
		"-DLLVM_BUILD_TESTS=OFF"
		"-DLLVM_INCLUDE_TESTS=OFF"
		"-DLLVM_INCLUDE_DOCS=OFF"
		"-DLLVM_INCLUDE_UTILS=OFF"
		"-DLLVM_BUILD_UTILS=OFF"
		"-DLLVM_USE_HOST_TOOLS=OFF"
		"-DLLVM_ENABLE_ZLIB=OFF"
		"-DLLVM_ENABLE_ZSTD=OFF"
		"-DCLANG_BUILD_TOOLS=OFF"
		"-DCLANG_ENABLE_ARCMT=OFF"
		"-DCLANG_ENABLE_STATIC_ANALYZER=OFF"
		"-DCLANG_INCLUDE_TESTS=OFF"
		"-DCLANG_INCLUDE_DOCS=OFF"
		"-DLLVM_ENABLE_IDE=ON"
		"-DLLVM_ADD_NATIVE_VISUALIZERS_TO_SOLUTION=OFF"
		"-DCLANG_LINK_CLANG_DYLIB=OFF"
		"-DLLVM_BUILD_LLVM_DYLIB=OFF"
		"-DLLVM_LINK_LLVM_DYLIB=OFF"
		"-DLLVM_INCLUDE_EXAMPLES=OFF"
		"-DLLVM_INCLUDE_RUNTIMES=OFF"
		"-DLLVM_INCLUDE_BENCHMARKS=OFF"
		"-DLLDB_ENABLE_PYTHON=OFF"
		"-DLLDB_ENABLE_LIBEDIT=OFF"
		"-DLLDB_ENABLE_CURSES=OFF"
		"-DPython3_EXECUTABLE=${PYTHON}"
	)
	cmake -GNinja "${mycmakeargs[@]}" "${S}/llvm" || die
	# shellcheck disable=SC2034
	local clangLibs=(
		libclangAST.a
		libclangCodeGen.a
		libclangDriver.a
		libclangEdit.a
		libclangFrontend.a
		libclangLex.a
		libclangParse.a
		libclangRewrite.a
		libclangRewriteFrontend.a
		libclangSema.a
		libclangSerialization.a
	)
	# shellcheck disable=SC2034
	local llvmLibs=(
		libLLVMCore.a
		libLLVMExecutionEngine.a
		libLLVMipo.a
		libLLVMMCJIT.a
		libLLVMDebugInfoDWARF.a
		libLLVMDemangle.a
		libLLVMBinaryFormat.a
		libLLVMDebugInfoPDB.a
	)
	# reduced list of targets but fragile.
	ninja llvm-config clang-headers llvm-headers "${clangLibs[@]}" "${llvmLibs[@]}" || die
	# May want to use llvm-libraries clang-libraries instead but that will build
	# to many redundant files.
	popd || die
}

src_configure() {
	build_llvm_host
	build_llvm_libs
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
		"-DLLVM_TARGETS_TO_BUILD=X86;ARM;AArch64"
		"-DLLDB_EXTERNAL_CLANG_RESOURCE_DIR=$(tc-getCC --print-resource-dir)"
		"-DLLDB_INCLUDE_TESTS=OFF"
		"-DCMAKE_CROSSCOMPILING=ON"
		"-DLLVM_BUILD_TESTS=OFF"
		"-DLLVM_INCLUDE_TESTS=OFF"
		"-DLLVM_INCLUDE_DOCS=OFF"
		"-DLLVM_INCLUDE_UTILS=OFF"
		"-DLLVM_BUILD_UTILS=OFF"
		"-DLLVM_USE_HOST_TOOLS=OFF"
		"-DLLDB_ENABLE_LUA=OFF"
		"-DLLVM_ENABLE_IDE=ON"
		"-DLLDB_ENABLE_PYTHON=OFF"
		"-DLLDB_ENABLE_LIBEDIT=OFF"
		"-DLLDB_ENABLE_CURSES=OFF"
		"-DLLDB_TABLEGEN_EXE=${PWD}/llvm_build_host/bin/lldb-tblgen"
		"-DLLVM_TABLEGEN=${PWD}/llvm_build_host/bin/llvm-tblgen"
		"-DLLVM_DIR=${PWD}/llvm_build/lib/cmake/llvm"
		"-DLLVM_BINARY_DIR=${PWD}/llvm_build"
		"-DLLVM_HOST_TRIPLE=${CHOST}"
		"-DPython3_EXECUTABLE=${PYTHON}"
	)

	append-cppflags "-I${S}/llvm/include"
	append-cppflags "-I${S}/clang/include"
	append-cppflags "-I${PWD}/llvm_build/include"
	append-cppflags "-I${PWD}/llvm_build/tools/clang/include"
	append-ldflags "-L${PWD}/llvm_build/lib"
	append-ldflags "-L${PWD}/llvm_build/tools/clang/lib"

	echo "configuring lldb"
	cmake_src_configure
}

src_compile() {
	cmake_src_compile lldb-server
}

src_install() {
	# shellcheck disable=SC2154
	dobin "${BUILD_DIR}"/bin/lldb-server
}
