# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="14f0776550b5a49e1c42f49a00213f7f3fa047bf"
CROS_WORKON_TREE="61008e62ee9355dc4f54966bb66709274963c4ad"
PYTHON_COMPAT=( python3_{8..11} )

inherit cros-constants

CROS_WORKON_REPO="${CROS_GIT_HOST_URL}"
CROS_WORKON_PROJECT="external/github.com/llvm/llvm-project"
CROS_WORKON_LOCALNAME="llvm-project"
CROS_WORKON_EGIT_BRANCH="main"
# TODO: Remove this one this package can be upreved by PUPr
CROS_WORKON_MANUAL_UPREV=1

# When building the 9999 ebuild, cros-workon will `rsync --exclude=.git` the
# project, so we don't have access to the git repository. When building a
# versioned ebuild, cros-workon will create a shallow clone that has a .git
# directory. So we need to use the PRECLONE_HOOK in the 9999 case to calculate
# the SVN revision.
if [[ "${PV}" == "9999" ]]; then
	# shellcheck disable=SC2034
	CROS_WORKON_PRECLONE_HOOK="cros-llvm_default_preclone_hook"
fi

inherit toolchain-funcs cros-workon cmake git-r3 cros-llvm python-any-r1

EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project
	${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project"
EGIT_BRANCH=main

# LLVM_HASH is no longer used by this ebuild, but is necessary
# still while we update the toolchain-utils scripts to support
# its absence. The new LLVM_HASH is stored in the _toolchain.xml
# manifest file.
# shellcheck disable=SC2034
LLVM_HASH="14f0776550b5a49e1c42f49a00213f7f3fa047bf" # r498229
LLVM_NEXT_HASH="14f0776550b5a49e1c42f49a00213f7f3fa047bf" # r498229

DESCRIPTION="OpenCL C library"
HOMEPAGE="https://libclc.llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions || ( MIT BSD )"
SLOT="0"
KEYWORDS="*"
IUSE=""
if [[ "${PV}" != "9999" ]]; then
	IUSE+=" llvm-next llvm-tot"
fi

DEPEND=""
RDEPEND=""
BDEPEND="${PYTHON_DEPS}
	>=sys-devel/llvm-${PV}[spirv-translator]
"

src_unpack() {
	export CMAKE_USE_DIR="${S}/libclc"
	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next || use llvm-tot; then
			# According to cros-workon, CROS_WORKON_COMMIT cannot be enabled in
			# a 9999 ebuild.
			# We also want to override it when we're using llvm-next or llvm-tot.
			# We need to specify that this doesn't get removed by portage_util.
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
	local mycmakeargs=(
		-DLIBCLC_TARGETS_TO_BUILD="spirv-mesa3d-;spirv64-mesa3d-"
		-DLLVM_CONFIG="${BROOT}/usr/bin/llvm-config"
		-DLLVM_SPIRV="${BROOT}/usr/bin/llvm-spirv"
	)
	cmake_src_configure
}
