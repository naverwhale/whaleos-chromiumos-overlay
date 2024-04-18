# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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
KEYWORDS="~*"
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
