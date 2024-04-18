# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "a5fdbbc61818ef9812202876f2ee071eb9c7785a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk flex_bluetooth .gn"

PLATFORM_SUBDIR="flex_bluetooth"

inherit cros-workon platform

DESCRIPTION="Apply (Floss) Bluetooth overrides for ChromeOS Flex"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/flex_bluetooth"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

platform_pkg_test() {
	platform_test "run" "${OUT}/flex_bluetooth_overrides_test"
}
