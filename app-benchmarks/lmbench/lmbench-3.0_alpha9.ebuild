# Copyright 1999-2009 Gentoo Foundation
# Copyright 2014 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils toolchain-funcs multilib

MY_P=${P/_alpha/-a}
DESCRIPTION="Suite of simple, portable benchmarks"
HOMEPAGE="http://www.bitmover.com/lmbench/whatis_lmbench.html"
SRC_URI="mirror://sourceforge/${PN}/development/${MY_P}/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	net-libs/libtirpc
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
	"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	sed -i \
		-e "/\$(BASE)\/lib/s:/lib:/$(get_libdir):g" \
		-e '/-ranlib/s:ranlib:$(RANLIB):' \
		src/Makefile || die
	epatch "${FILESDIR}/lmbench-cflags.patch"
}

src_compile() {
	emake \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		CC="$(tc-getCC)" \
		EXTRA_CFLAGS="$($(tc-getPKG_CONFIG) libtirpc --cflags)" \
		LDLIBS="$($(tc-getPKG_CONFIG) libtirpc --libs)" \
		build
}

src_install() {
	cd src
	emake BASE="${ED}"/usr install

	dodir /usr/share
	mv "${ED}"/usr/man "${ED}"/usr/share || die

	cd "${S}"
	mv "${ED}"/usr/bin/stream{,.lmbench}  || die

	# avoid file collision with sys-apps/util-linux
	mv "${ED}"/usr/bin/line{,.lmbench} || die
}
