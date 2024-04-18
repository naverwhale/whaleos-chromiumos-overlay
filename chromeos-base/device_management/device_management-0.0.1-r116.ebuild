# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "e385dba766d3c4dae0b8471bb9753b700a4cd315" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
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
KEYWORDS="*"
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
