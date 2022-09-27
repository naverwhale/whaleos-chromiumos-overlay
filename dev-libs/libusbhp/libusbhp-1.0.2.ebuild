# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils

DESCRIPTION="Usb Hotplug Library"
HOMEPAGE="http://www.aasimon.org/libusbhp/"
SRC_URI="http://www.aasimon.org/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="
	virtual/udev
"

DEPEND="
	${RDEPEND}
	dev-util/pkgconfig
"

src_configure() {
	econf \
		$(use_enable static-libs static) \
		--without-debug
}

src_install() {
	default
	use static-libs || find "${ED}" -name '*.la' -delete
}
