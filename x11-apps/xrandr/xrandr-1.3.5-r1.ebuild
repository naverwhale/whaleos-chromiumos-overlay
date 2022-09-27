# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xrandr/xrandr-1.3.5.ebuild,v 1.7 2011/10/03 17:58:09 josejx Exp $

EAPI=4

inherit xorg-2

DESCRIPTION="primitive command line interface to RandR extension"

KEYWORDS="*"
IUSE=""

RDEPEND=">=x11-libs/libXrandr-1.3
	x11-libs/libXrender
	x11-libs/libX11"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gammafix.patch
}

src_install() {
	xorg-2_src_install
	rm -f "${ED}"/usr/bin/xkeystone || die
}
