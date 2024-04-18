# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="14f0776550b5a49e1c42f49a00213f7f3fa047bf"
CROS_WORKON_TREE="61008e62ee9355dc4f54966bb66709274963c4ad"
CROS_WORKON_REPO="${CROS_GIT_HOST_URL}"
CROS_WORKON_PROJECT="external/github.com/llvm/llvm-project"
CROS_WORKON_LOCALNAME="llvm-project"

if [[ "${PV}" == "9999" ]]; then
	# shellcheck disable=SC2034
	CROS_WORKON_PRECLONE_HOOK="cros-llvm_default_preclone_hook"
fi

inherit eutils toolchain-funcs cros-constants cmake git-2 cros-llvm cros-workon

EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project
	${CROS_GIT_HOST_URL}/external/github.com/llvm/llvm-project"
EGIT_BRANCH=main

DESCRIPTION="LLVM libc"
HOMEPAGE="https://libc.llvm.org"

LICENSE="LLVM-exception"
SLOT="0"
KEYWORDS="*"
IUSE="llvm-next continue-on-patch-failure"
DEPEND=""
BDEPEND="sys-devel/llvm"

pkg_setup() {
	setup_cross_toolchain
	export CMAKE_USE_DIR="${S}/llvm"
}

src_unpack() {
	if [[ "${PV}" != "9999" ]]; then
		if use llvm-next; then
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
	append-lfs-flags
	append-cppflags "-DNDEBUG"

	local mycmakeargs=(
		"-GNinja"
		"-DLLVM_ENABLE_PROJECTS=libc"
		"-DCMAKE_BUILD_TYPE=MinSizeRel"
		"-DLLVM_LIBC_INCLUDE_SCUDO=OFF"
		"-DLLVM_LIBC_FULL_BUILD=ON"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install install-libc || die
}
