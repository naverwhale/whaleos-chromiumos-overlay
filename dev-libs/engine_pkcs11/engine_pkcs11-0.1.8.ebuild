# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/engine_pkcs11/engine_pkcs11-0.1.8.ebuild,v 1.2 2010/02/15 19:55:35 josejx Exp $

EAPI=6

if [[ "${PV}" = "9999" ]]; then
	inherit autotools subversion
	ESVN_REPO_URI="http://www.opensc-project.org/svn/${PN}/trunk"
else
	SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.gz"
fi

DESCRIPTION="engine_pkcs11 is an implementation of an engine for OpenSSL"
HOMEPAGE="http://www.opensc-project.org/engine_pkcs11"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND=">=dev-libs/libp11-0.2.5
	dev-libs/openssl:0="
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-0.1.8-Fixes-for-OpenSSL-1.1-build.patch"
)

if [[ "${PV}" = "9999" ]]; then
	DEPEND="${DEPEND}
		app-text/docbook-xsl-stylesheets
		dev-libs/libxslt"

	src_prepare() {
		default
		eautoreconf
	}
fi

src_configure() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--htmldir="/usr/share/doc/${PF}/html" \
		$(use_enable doc)
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
}
