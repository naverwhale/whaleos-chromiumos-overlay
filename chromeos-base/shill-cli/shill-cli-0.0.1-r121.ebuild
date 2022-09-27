# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="54c7fac37782fd4a975d5ac8982da4ef9423fda7"
CROS_WORKON_TREE=("d897a7a44e07236268904e1df7f983871c1e1258" "89de54f8e343342fc28d319632ee165e9bca94f9" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk shill/cli .gn"

PLATFORM_SUBDIR="shill/cli"

inherit cros-workon platform

DESCRIPTION="Shill Command Line Interface"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/shill/cli"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=chromeos-base/shill-0.0.1-r2205
"

DEPEND="
	chromeos-base/shill-client:=
	chromeos-base/system_api:=
"

src_install() {
	dobin "${OUT}"/shillcli
}

platform_pkg_test() {
	platform_test "run" "${OUT}/shillcli_test"
}
