# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "6c6f4b9f236258999952e8b874c5f68f77f83ad8" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk lorgnette .gn"

PLATFORM_SUBDIR="lorgnette/client"

inherit cros-workon platform

DESCRIPTION="ChromeOS lorgnette client library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/lorgnette/client/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="
	chromeos-base/system_api:=[fuzzer?]
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
	platform_src_install

	platform_install_dbus_client_lib "lorgnette"
}
