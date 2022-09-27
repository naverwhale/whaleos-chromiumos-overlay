# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="cf6a1b2ded4b3a8fe0855eefc127c35b7912b5ac"
CROS_WORKON_TREE="8e73b869e4aa9bd7f07a795f5db5f21126175d6e"
CROS_WORKON_PROJECT="chromiumos/third_party/huddly-updater"

inherit cros-debug cros-workon libchrome udev user

DESCRIPTION="A utility to update Huddly camera firmware"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/huddly-updater"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

COMMON_DEPEND="chromeos-base/libbrillo:=
	chromeos-base/cfm-dfu-notification:=
	dev-libs/msgpack:=
	virtual/libusb:1
	virtual/libudev:0=
"

DEPEND="${COMMON_DEPEND}
	test? ( dev-cpp/gtest:= )
"

RDEPEND="${COMMON_DEPEND}
	app-arch/unzip
"

src_configure() {
	# See crbug/1078297
	cros-debug-add-NDEBUG
	default
}

src_test() {
	if use amd64; then
		emake tests
	fi
}

src_install() {
	dosbin huddly-updater
	dosbin huddly-hpk-updater
	udev_dorules conf/99-huddly.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
