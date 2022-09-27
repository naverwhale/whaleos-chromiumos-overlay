# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cros-sanitizers eutils autotools

DESCRIPTION="Epson Inkjet Printer Driver (ESC/P-R)"
HOMEPAGE="http://download.ebz.epson.net/dsc/search/01/search/?OSC=LX"
SRC_URI="https://download3.ebz.epson.net/dsc/f/03/00/10/33/90/13c8b802beeae061b6eb08248a0417be08484a26/epson-inkjet-printer-escpr-1.7.6-1lsb3.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/1.6.5-warnings.patch"
	"${FILESDIR}/${PN}-1.6.10-search-filter.patch"
	"${FILESDIR}/${PN}-1.7.6-cupsRasterHeader.patch"
	"${FILESDIR}/${PN}-1.7.6-writeToNullFix2.patch"
)

src_prepare() {
	epatch "${PATCHES[@]}"
	epatch_user
	eautoreconf
}

src_configure() {
	sanitizers-setup-env
	econf --disable-shared

	# Makefile calls ls to generate a file list which is included in Makefile.am
	# Set the collation to C to avoid automake being called automatically
	unset LC_ALL
	export LC_COLLATE=C
}

src_install() {
	emake -C src DESTDIR="${D}" install
}
