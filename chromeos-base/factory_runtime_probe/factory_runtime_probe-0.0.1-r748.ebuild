# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "1dd32d7b19a6a6a68a55cafb76e0dd5f0d9c5407" "05a052ec9a484e721478c7bb3e5e8e76c4ddc016" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk chromeos-config libcrossystem libec runtime_probe mojo_service_manager .gn"

PLATFORM_SUBDIR="runtime_probe/factory_runtime_probe"

inherit cros-workon cros-unibuild platform

DESCRIPTION="Device component probe tool **for factory environment**."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/runtime_probe/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros-debug test"

# TODO(yhong): Extract common parts with runtime_probe-9999.ebuild to a shared
#     eclass.

COMMON_DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/cros-camera-libs:=
	chromeos-base/debugd-client:=
	chromeos-base/diagnostics:=
	chromeos-base/libcrossystem:=[test?]
	chromeos-base/libec:=
	chromeos-base/mojo_service_manager:=
	chromeos-base/shill-client:=
	dev-libs/libpcre:=
	dev-libs/protobuf:=
	media-libs/minigbm:=
	virtual/libusb:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/system_api:=[fuzzer?]
"

platform_pkg_test() {
	platform test_all
}
