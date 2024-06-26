# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="be224cb99905ee962f4010c0fe3287997341b122"
CROS_WORKON_TREE="c2a4de3ea965f3a166ad88f1be45a3c7b012e995"
CROS_WORKON_PROJECT="chromiumos/third_party/mimo-updater"

inherit cros-debug cros-workon libchrome udev user

DESCRIPTION="A tool to interact with a Mimo device from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/mimo-updater"

LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="
	chromeos-base/libbrillo:=
	virtual/libusb:1
	virtual/libudev:0="

RDEPEND="${DEPEND}"

src_configure() {
	# See crbug/1078297
	cros-debug-add-NDEBUG
	default
}

src_install() {
	dosbin mimo-updater
	udev_dorules conf/90-displaylink-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
