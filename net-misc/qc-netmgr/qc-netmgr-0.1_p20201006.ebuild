# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-sanitizers user

DESCRIPTION="Qualcomm modem data service"
HOMEPAGE="https://source.codeaurora.org/quic/dataservices/modem-data-manager/log/?h=LC.UM.1.0"
#GIT_SHA1="30861158603e1304444d0d48c9a2e990bcaa7103"
SRC_URI="https://source.codeaurora.org/quic/dataservices/modem-data-manager/log/?h=LC.UM.1.0 -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="asan +seccomp"

DEPEND="net-libs/librmnetctl
	net-libs/libqrtr
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/modem-data-manager"

PATCHES=(
	"${FILESDIR}"/0001-Fix-modem-configuration.patch
	"${FILESDIR}"/0002-Fix-Makefile-to-add-to-LDFLAGS.patch
)

src_configure() {
	sanitizers-setup-env
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" install

	insinto /etc/init
	doins "${FILESDIR}/qc-netmgr.conf"
}
