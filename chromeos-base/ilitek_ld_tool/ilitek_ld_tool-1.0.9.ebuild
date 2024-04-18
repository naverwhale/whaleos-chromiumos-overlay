# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Ilitek Touchscreen Tool for Firmware Update"
HOMEPAGE="https://github.com/ILITEK-JoeHung/ilitek_ld_tool"
SRC_URI="https://github.com/ILITEK-JoeHung/ilitek_ld_tool/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	tc-export CC
}

src_install() {
	dosbin ilitek_ld

	insinto /usr/share/${PN}
	doins "${FILESDIR}"/ilitek_fwid_map.csv
}
