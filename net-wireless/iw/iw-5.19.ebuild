# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="nl80211 configuration utility for wireless devices using the mac80211 stack"
HOMEPAGE="https://wireless.wiki.kernel.org/en/users/Documentation/iw"
SRC_URI="https://www.kernel.org/pub/software/network/${PN}/${P}.tar.xz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-libs/libnl:="
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-util-add-support-for-320Mhz-bandwidth.patch"
	"${FILESDIR}/${P}-util-add-support-for-320MHz-bandwidth-without-cf1.patch"
	"${FILESDIR}/${P}-iw-scan-set-NL80211_SCAN_FLAG_COLOCATED_6GHZ-in-case.patch"
	"${FILESDIR}/${P}-link-fix-some-formatting.patch"
	"${FILESDIR}/${P}-util-don-t-print-EHT-info-if-not-present.patch"
	"${FILESDIR}/${P}-iw-retain___stop___cmd.patch"
	"${FILESDIR}/${P}-iw-Do-not-compress-man-pages-by-default.patch"
)

src_prepare() {
	default
	tc-export CC LD PKG_CONFIG
}

src_compile() {
	CFLAGS="${CFLAGS} ${CPPFLAGS}"
	LDFLAGS="${CFLAGS} ${LDFLAGS}" emake V=1
}

src_install() {
	emake V=1 DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
