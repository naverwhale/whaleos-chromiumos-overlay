# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils

# This is a snapshot of "master" branch on 2016-05-31
GIT_SHA1="1341d561973b87238676950140ea91bd1b456bd8"
MY_P="${PN}-${GIT_SHA1}"
SRC_URI="https://github.com/richardeoin/ftx-prog/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Linux command-line alternative to the FTProg utility for FTDI's FT-X series of USB interfaces"
HOMEPAGE="https://github.com/richardeoin/ftx-prog"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=dev-embedded/libftdi-1.0"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/ftx-prog-20160531-libftdi1.patch
}

src_configure() {
	tc-export CC PKG_CONFIG
}

src_install() {
	dodoc README.md
	dobin ftx_prog
}
