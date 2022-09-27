# Copyright 2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cros-constants cmake-multilib git-2 cros-llvm toolchain-funcs

DESCRIPTION="lldb-server, for the LLDB debugger"
HOMEPAGE="https://github.com/llvm/llvm-project"
SRC_URI=""
EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project
	${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project"
EGIT_BRANCH=main

LLVM_HASH="cd442157cff4aad209ae532cbf031abbe10bc1df" # r422132
LLVM_NEXT_HASH="cd442157cff4aad209ae532cbf031abbe10bc1df" # r422132

LICENSE="|| ( UoI-NCSA MIT )"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host llvm-next llvm-tot"
RDEPEND=""

DEPEND="${RDEPEND}
	sys-libs/ncurses"

# CMAKE_BUILD_TYPE and CMAKE_MAKEFILE_GENERATOR are called by
# cmake-utils_src_configure and cmake-utils_src_make (which is called
# from cmake-utils_src_compile), respectively (see
# third_party/portage-stable/eclass/cmake-utils.eclass.
# shellcheck disable=SC2034
CMAKE_BUILD_TYPE=Release
# shellcheck disable=SC2034
CMAKE_MAKEFILE_GENERATOR=ninja

pkg_setup() {
	use cros_host && die "lldb is not supported for building on non-device builds"

	# Setup llvm toolchain for cross-compilation
	setup_cross_toolchain
	export CMAKE_USE_DIR="${S}/lldb"
}

src_unpack() {
	if use llvm-next || use llvm-tot; then
		export EGIT_COMMIT="${LLVM_NEXT_HASH}"
	else
		export EGIT_COMMIT="${LLVM_HASH}"
	fi
	git-2_src_unpack
}

src_prepare() {
	cmake-utils_src_prepare
	"${FILESDIR}"/patch_manager/patch_manager.py \
		--svn_version "$(get_most_recent_revision)" \
		--patch_metadata_file "${FILESDIR}"/PATCHES.json \
		--filesdir_path "${FILESDIR}" \
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
	)
	tc-env_build cmake -GNinja "${mycmakeargs[@]}" "${S}/llvm"
	ninja llvm-tblgen clang-tblgen lldb-tblgen
	popd || die
}

build_llvm() {
	echo "Cross-compiling llvm and clang libraries"
	mkdir llvm_build
	pushd llvm_build || die
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_ENABLE_PROJECTS=llvm;clang"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
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
	)
	cmake -GNinja "${mycmakeargs[@]}" "${S}/llvm"
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
	ninja llvm-config clang-headers llvm-headers llvm-libraries clang-libraries
	popd || die
}

src_configure() {
	build_llvm_host
	build_llvm
	local libdir=$(get_libdir)
	local mycmakeargs=(
		"${mycmakeargs[@]}"
		"-DLLVM_LIBDIR_SUFFIX=${libdir#lib}"
		"-DCMAKE_INSTALL_PREFIX=${PREFIX}"
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
	)

	append-cppflags "-I${S}/llvm/include"
	append-cppflags "-I${S}/clang/include"
	append-cppflags "-I${PWD}/llvm_build/include"
	append-cppflags "-I${PWD}/llvm_build/tools/clang/include"
	append-ldflags "-L${PWD}/llvm_build/lib"
	append-ldflags "-L${PWD}/llvm_build/tools/clang/lib"

	echo "configuring lldb"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile lldb-server
}

src_install() {
	# shellcheck disable=SC2154
	dobin "${BUILD_DIR}"/bin/lldb-server
}
