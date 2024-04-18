# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="a8ca488be43b474e72eb3fc36a669806bdc6883d"
CROS_WORKON_TREE="22c7b2e70950801defe334508db189f248c15906"
CROS_WORKON_PROJECT="chromiumos/third_party/sis-updater"

inherit cros-workon cros-common.mk libchrome udev user

DESCRIPTION="A tool to update SiS firmware on Mimo from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/sis-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/libbrillo:="

RDEPEND="${DEPEND}"

src_install() {
	dosbin "${OUT}/sis-updater"
	udev_dorules conf/99-sis-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
