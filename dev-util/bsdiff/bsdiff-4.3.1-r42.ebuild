# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bsdiff/bsdiff-4.3-r2.ebuild,v 1.1 2010/12/13 00:35:03 flameeyes Exp $

EAPI=7

CROS_WORKON_COMMIT=("19c803df4bc92b9ef7f6cec83fdff98b144f06f0" "ed2a90db11ed082ec1969d117587426b645303ac")
CROS_WORKON_TREE=("e8224fd5df0b5d89e3ac923aef06ecf7ccce51f1" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "4f60cc104be3c4d98888fedc7529c8ca449fe405")
inherit cros-constants

# cros-workon expects the repo to be in src/third_party, but is in src/aosp.
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/external/bsdiff")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/bsdiff")
CROS_WORKON_EGIT_BRANCH=("main" "master")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/bsdiff")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_AOSP_URL}")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_MANUAL_UPREV=1
CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="bsdiff"

inherit cros-workon platform

DESCRIPTION="bsdiff: Binary Differencer using a suffix alg"
HOMEPAGE="http://www.daemonology.net/bsdiff/"
SRC_URI=""

LICENSE="BSD-2"
KEYWORDS="*"

RDEPEND="
	>=app-arch/brotli-1.0.6:=
	app-arch/bzip2:=
	dev-libs/libdivsufsort:=
"
DEPEND="${RDEPEND}"

src_install() {
	platform_src_install

	if use cros_host; then
		dobin "${OUT}"/bsdiff
		dobin "${OUT}"/bspatch
	fi
	dolib.a "${OUT}"/libbsdiff.a
	dolib.a "${OUT}"/libbspatch.a

	insinto /usr/include
	doins -r include/bsdiff

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libbsdiff.pc libbspatch.pc

	local fuzzer_component_id="31714"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bspatch_fuzzer \
		--comp "${fuzzer_component_id}"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/bsdiff_test"
}
