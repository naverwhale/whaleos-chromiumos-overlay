# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk device_management libhwsec-foundation .gn"

PLATFORM_SUBDIR="device_management/client"

inherit cros-workon platform

DESCRIPTION="Device Management D-Bus client library for ChromiumOS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/device_management/client"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE=""

DEPEND="
	chromeos-base/system_api:=
"

RDEPEND="${DEPEND}"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
	platform_src_install

	# Install D-Bus client library.
	platform_install_dbus_client_lib "device_management"
}
