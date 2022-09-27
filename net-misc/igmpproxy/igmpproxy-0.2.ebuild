# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils linux-info systemd

DESCRIPTION="Multicast Routing Daemon using only IGMP signalling"
HOMEPAGE="https://github.com/pali/igmpproxy"
SRC_URI="https://github.com/pali/igmpproxy/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2 Stanford"
SLOT="0"
KEYWORDS="*"
IUSE=""

CONFIG_CHECK="~IP_MULTICAST ~IP_MROUTE"

src_prepare() {
	epatch "${FILESDIR}/patches/${PN}-0.2-send-updated-report.patch"
	epatch "${FILESDIR}/patches/${PN}-0.2-configure-queryinterval-and-reportforwarding.patch"
	epatch "${FILESDIR}/patches/${PN}-0.2-fix-timer-issues.patch"
	epatch "${FILESDIR}/patches/${PN}-0.2-configure-router-robustness-value.patch"
}

src_install() {
	emake DESTDIR="${D}" install
	newinitd "${FILESDIR}/${PN}-init.d" ${PN}
	newconfd "${FILESDIR}/${PN}-conf.d" ${PN}
	systemd_dounit "${FILESDIR}/${PN}.service"
}
