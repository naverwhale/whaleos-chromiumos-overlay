# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "4376098c685982a6b43bac65b18b49b18da4227f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk pciguard .gn"

PLATFORM_SUBDIR="pciguard"

inherit cros-workon platform user

DESCRIPTION="Chrome OS External PCI device security daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/pciguard/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	chromeos-base/session_manager-client:=
	chromeos-base/system_api:=
"

pkg_preinst() {
	enewuser pciguard
	enewgroup pciguard
	cros-workon_pkg_setup
}

platform_pkg_test() {
	platform test_all
}
