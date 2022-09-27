# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="QCA NSS firmware"
HOMEPAGE="https://github.com/qca/nss-firmware"

SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="LICENSE.qca-nss-firmware"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/${P}

src_install() {
	insinto /lib/firmware
	newins R/retail_router0.bin qca-nss0.bin
	newins R/retail_router1.bin qca-nss1.bin
}
