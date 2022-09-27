# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit toolchain-funcs

DESCRIPTION="Download agent tool for MediaTek platform"
SRC_URI="https://github.com/mtk09422/chromiumos-third_party-mediatek-datool/archive/v${PV}.tar.gz -> ${P}.tar.gz"
HOMEPAGE="https://github.com/mtk09422/chromiumos-third_party-mediatek-datool/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}/chromiumos-third_party-mediatek-${P}

src_configure() {
	tc-export CC
}

src_compile() {
	emake
}

src_install() {
	dosbin fbtool
}
