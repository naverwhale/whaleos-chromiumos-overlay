# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk cryptohome .gn"

PLATFORM_SUBDIR="cryptohome/bootlockbox-client"

inherit cros-workon platform

DESCRIPTION="BootLockbox DBus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cryptohome/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library.
BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
	# Export neccessary header files:
	insinto /usr/include/bootlockbox-client/bootlockbox
	doins ../bootlockbox/boot_lockbox_client.h

	# Export necessary for crytphome header files:
	insinto /usr/include/cryptohome/bootlockbox
	doins "${OUT}"/gen/include/cryptohome/bootlockbox/*.h

	dolib.a "${OUT}"/libbootlockbox-proto.a
	# Install libbootlockbox-client.so:
	dolib.so "${OUT}"/lib/libbootlockbox-client.so

	# Install DBus client library.
	platform_install_dbus_client_lib "bootlockbox"
}
