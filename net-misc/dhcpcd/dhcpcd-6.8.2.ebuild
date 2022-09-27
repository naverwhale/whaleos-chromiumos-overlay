# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/dhcpcd/dhcpcd-6.8.2.ebuild,v 1.1 2015/05/05 13:20:12 williamh Exp $

EAPI=5

MY_P="${P/_alpha/-alpha}"
MY_P="${MY_P/_beta/-beta}"
MY_P="${MY_P/_rc/-rc}"
SRC_URI="http://roy.marples.name/downloads/${PN}/${MY_P}.tar.bz2"
KEYWORDS="*"
S="${WORKDIR}/${MY_P}"

inherit cros-sanitizers eutils systemd toolchain-funcs user

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"
SLOT="0"
IUSE="elibc_glibc +embedded ipv6 kernel_linux +udev +dbus"

COMMON_DEPEND="udev? ( virtual/udev )
	       dbus? ( sys-apps/dbus )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_prepare()
{
	epatch "${FILESDIR}"/patches/${P}-Optionally-ARP-for-gateway-IP-address.patch
	epatch "${FILESDIR}"/patches/${P}-Teach-DHCP-client-to-do-unicast-ARP-for-gatew.patch
	epatch "${FILESDIR}"/patches/${P}-Fix-dhcpcd-running-as-a-regular-user.patch
	epatch "${FILESDIR}"/patches/${P}-Allow-lease-file-to-be-set-on-command-line.patch
	epatch "${FILESDIR}"/patches/${P}-Be-more-permissive-on-NAKs.patch
	epatch "${FILESDIR}"/patches/${P}-Accept-an-ACK-after-a-NAK.patch
	epatch "${FILESDIR}"/patches/${P}-Track-and-validate-disputed-addresses.patch
	epatch "${FILESDIR}"/patches/${P}-Fix-OOB-read-in-dhcpcd.patch
	epatch "${FILESDIR}"/patches/${P}-Merge-in-DHCP-options-from-the-original-offer.patch
	epatch "${FILESDIR}"/patches/${P}-Stop-ARP-probes-when-conflict-is-detected.patch
	epatch "${FILESDIR}"/patches/${P}-Add-option-definition-for-Web-Proxy-Auto-Discovery.patch
	epatch "${FILESDIR}"/patches/${P}-Add-RPC-support-for-DHCPv4-client.patch
	epatch "${FILESDIR}"/patches/${P}-UPSTREAM-Fix-ARP-checking.patch
	epatch "${FILESDIR}"/patches/${P}-Add-ability-to-disable-hook-scripts.patch
	epatch "${FILESDIR}"/patches/${P}-Improve-debugability.patch
	epatch "${FILESDIR}"/patches/${P}-Add-DBus-RPC-support.patch
	epatch "${FILESDIR}"/patches/${P}-ChromiumOS-DHCPv6-support.patch
	epatch "${FILESDIR}"/patches/${P}-UPSTREAM-Zero-Length-Embedded-Option.patch
	epatch "${FILESDIR}"/patches/${P}-DHCPv6-Fix-prefix-delegation-lease-file-name.patch
	epatch "${FILESDIR}"/patches/${P}-Ensure-Gateway-Probe-Is-Broadcast.patch
	epatch "${FILESDIR}"/patches/${P}-UPSTREAM-Fix-heap-based-overflow-in-dhcp_envoption1.patch
	epatch "${FILESDIR}"/patches/${P}-UPSTREAM-Ensure-that-option-length-fits-inside-data-length-less-option-size.patch
	epatch "${FILESDIR}"/patches/${P}-Change-vendor_encapsulated_options-to-binhex.patch
	epatch "${FILESDIR}"/patches/${P}-Handle-DHCP-iSNS-option.patch
	epatch "${FILESDIR}"/patches/${P}-Send-more-DHCPv6-options-over-DBus-RPC.patch
	epatch "${FILESDIR}"/patches/${P}-Fix-dbus-flags.patch
	epatch "${FILESDIR}"/patches/${P}-Check-read-callbacks-before-execution.patch
}

src_configure()
{
	sanitizers-setup-env

	local dev hooks
	use udev || dev="--without-dev --without-udev"
	if ! use dbus ; then
		hooks="--with-hook=ntp.conf"
		use elibc_glibc && hooks="${hooks} --with-hook=yp.conf"
	fi
	econf \
		--prefix= \
		--libexecdir=/lib/dhcpcd \
		--dbdir=/var/lib/dhcpcd \
		--rundir=/run/dhcpcd \
		$(use_enable embedded) \
		$(use_enable ipv6) \
		$(use_enable dbus) \
		${dev} \
		CC="$(tc-getCC)" \
		${hooks}
	# Update DUID file path so it is writable by dhcp user.
	echo '#define DUID DBDIR "/" PACKAGE ".duid"' >> "${S}/config.h"
}

src_install()
{
	default
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}

pkg_preinst()
{
	enewuser "dhcp"
	enewgroup "dhcp"
}

pkg_postinst()
{
	# Upgrade the duid file to the new format if needed
	local old_duid="${ROOT}"/var/lib/dhcpcd/dhcpcd.duid
	local new_duid="${ROOT}"/etc/dhcpcd.duid
	if [ -e "${old_duid}" ] && ! grep -q '..:..:..:..:..:..' "${old_duid}"; then
		sed -i -e 's/\(..\)/\1:/g; s/:$//g' "${old_duid}"
	fi

	# Move the duid to /etc, a more sensible location
	if [ -e "${old_duid}" -a ! -e "${new_duid}" ]; then
		cp -p "${old_duid}" "${new_duid}"
	fi

	if [ -z "$REPLACING_VERSIONS" ]; then
		elog
		elog "dhcpcd has zeroconf support active by default."
		elog "This means it will always obtain an IP address even if no"
		elog "DHCP server can be contacted, which will break any existing"
		elog "failover support you may have configured in your net configuration."
		elog "This behaviour can be controlled with the noipv4ll configuration"
		elog "file option or the -L command line switch."
		elog "See the dhcpcd and dhcpcd.conf man pages for more details."

		elog
		elog "Dhcpcd has duid enabled by default, and this may cause issues"
		elog "with some dhcp servers. For more information, see"
		elog "https://bugs.gentoo.org/show_bug.cgi?id=477356"
	fi

	if ! has_version net-dns/bind-tools; then
		elog
		elog "If you activate the lookup-hostname hook to look up your hostname"
		elog "using the dns, you need to install net-dns/bind-tools."
	fi
}
