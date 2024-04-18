# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

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

DESCRIPTION="LLVM scudo_standalone memory allocator"
HOMEPAGE="http://compiler-rt.llvm.org/"

LICENSE="LLVM-exception"
SLOT="0"
KEYWORDS="~*"
IUSE="continue-on-patch-failure system_wide_scudo"
if [[ "${PV}" != "9999" ]]; then
	IUSE+=" llvm-next"
fi
BDEPEND="
	sys-devel/llvm
	${PYTHON_DEPS}
"
DEPEND="sys-libs/libxcrypt"

pkg_setup() {
	export CMAKE_USE_DIR="${S}/compiler-rt"
}

src_unpack() {
	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next; then
			# According to cros-workon, CROS_WORKON_COMMIT cannot be
			# enabled in a 9999 ebuild. We also want to override it
			# when we're using llvm-next. We need to specify that
			# this doesn't get removed by portage_util.
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

	eapply_user
	cmake_src_prepare
}

src_configure() {
	BUILD_DIR="${WORKDIR}/${P}_build"
	append-lfs-flags
	append-flags -DUSE_CHROMEOS_CONFIG

	local mycmakeargs=(
		"-DCOMPILER_RT_BUILD_CRT=no"
		"-DCOMPILER_RT_USE_LIBCXX=yes"
		"-DCOMPILER_RT_LIBCXXABI_PATH=${S}/libcxxabi"
		"-DCOMPILER_RT_LIBCXX_PATH=${S}/libcxx"
		"-DCOMPILER_RT_HAS_GNU_VERSION_SCRIPT_COMPAT=no"
		"-DCOMPILER_RT_BUILTINS_HIDE_SYMBOLS=OFF"
		"-DCOMPILER_RT_BUILD_SANITIZERS=yes"
		"-DCOMPILER_RT_BUILD_LIBFUZZER=no"
		"-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=${CTARGET}"
		"-DCOMPILER_RT_TEST_TARGET_TRIPLE=${CTARGET}"

		# We require gwp_asan as we want it built within the scudo dso
		"-DCOMPILER_RT_SANITIZERS_TO_BUILD=scudo_standalone;gwp_asan"
		"-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF"
		"-DCOMPILER_RT_BUILD_ORC=OFF"
		"-DCOMPILER_RT_INSTALL_PATH=${EPREFIX}$(${CC} --print-resource-dir)"
	)

	cmake_src_configure
}

src_install() {
	local arch
	case "${ARCH}" in
		x86) arch='i386';;
		amd64) arch='x86_64';;
		arm) arch='armhf';;
		arm64) arch='aarch64';;
		*) die "unknown ARCH '${ARCH}'";;
	esac

	# Install the scudo_standalone .so
	local libname="libclang_rt.scudo_standalone-${arch}.so"
	dolib.so "${BUILD_DIR}/lib/linux/${libname}"
}
