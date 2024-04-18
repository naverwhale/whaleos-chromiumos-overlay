# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "5bf947979813d481d14995861aa5ba98fa78f419" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk bootlockbox .gn"

PLATFORM_SUBDIR="bootlockbox/client"

inherit cros-workon platform

DESCRIPTION="BootLockbox DBus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/bootlockbox/client/"

LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
	chromeos-base/system_api:=
"

# Workaround to rebuild this package on the chromeos-dbus-bindings update.
# Please find the comment in chromeos-dbus-bindings for its background.
# Workaround to rebuild this package when protoc is upgraded.
DEPEND="
	${RDEPEND}
	chromeos-base/chromeos-dbus-bindings:=
	dev-libs/protobuf:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	dev-libs/protobuf
"

src_install() {
	platform_src_install

	# Export neccessary header files:
	insinto /usr/include/bootlockbox-client/bootlockbox
	doins ../boot_lockbox_client.h

	# Export necessary for crytphome header files:
	insinto /usr/include/bootlockbox
	doins "${OUT}"/gen/include/bootlockbox/*.h

	dolib.a "${OUT}"/libbootlockbox-proto.a
	# Install libbootlockbox-client.so:
	dolib.so "${OUT}"/lib/libbootlockbox-client.so

	# Install DBus client library.
	platform_install_dbus_client_lib "bootlockbox"
}
