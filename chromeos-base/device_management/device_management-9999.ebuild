# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk device_management libhwsec libhwsec-foundation .gn"

PLATFORM_SUBDIR="device_management"

inherit cros-workon platform user

DESCRIPTION="Device Management service for ChromiumOS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/device_management/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="test tpm tpm_dynamic tpm_insecure_fallback tpm2"

RDEPEND="
	chromeos-base/libhwsec:=[test?]
	chromeos-base/libhwsec-foundation:=
	chromeos-base/device_management-client:=
	chromeos-base/minijail:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
"

DEPEND="${RDEPEND}
	chromeos-base/system_api:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

pkg_preinst() {
	enewuser "device_management"
	enewgroup "device_management"
}

platform_pkg_test() {
	platform test_all
}
