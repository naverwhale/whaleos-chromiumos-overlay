# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "7cfbcc7d45ba1b82a9d890f37f04b778f1882a09" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="common-mk chromeos-config libcrossystem libec rgbkbd .gn"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="rgbkbd"
# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon cros-unibuild platform tmpfiles user udev

DESCRIPTION="A daemon for controlling an RGB backlit keyboard."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/rgbkbd/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/libcrossystem:=[test?]
	chromeos-base/libec:=
	chromeos-base/system_api:=
	virtual/libusb:=
"

RDEPEND="
	${DEPEND}
	virtual/udev
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

pkg_preinst() {
	# Ensure that this group exists so that rgbkbd can access /dev/cros_ec.
	enewgroup "cros_ec-access"
	# Create user and group for RGBKBD.
	enewuser "rgbkbd"
	enewgroup "rgbkbd"
}

src_install() {
	platform_src_install

	# Create tmpfiles for testing.
	dotmpfiles tmpfiles.d/rgbkbd.conf

	udev_dorules udev/*.rules

	if use fuzzer; then
		local fuzzer_component_id="1131926"
		platform_fuzzer_install "${S}"/OWNERS \
			"${OUT}"/rgb_daemon_fuzzer \
			--comp "${fuzzer_component_id}"
	fi
}

platform_pkg_test() {
	platform test_all
}
