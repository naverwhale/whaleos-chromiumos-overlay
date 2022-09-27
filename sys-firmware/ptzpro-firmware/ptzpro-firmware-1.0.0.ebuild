# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Logitech PTZ Pro firmware"
SRC_URI="https://s3.amazonaws.com/chromiumos/ptzpro-bin/${P}.tar.gz"

LICENSE="BSD-Logitech"
SLOT="0"
KEYWORDS="*"

RDEPEND="sys-apps/logitech-updater"
DEPEND=""

S="${WORKDIR}"

src_install() {
	insinto /lib/firmware/logitech/ptzpro
	doins "ptzpro_video.bin"
	doins "ptzpro_eeprom.s19"
	doins "ptzpro_video.bin.sig"
	doins "ptzpro_eeprom.s19.sig"
}
