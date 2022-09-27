# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools flag-o-matic user systemd linux-info

DESCRIPTION="Robust and highly flexible tunneling application compatible with many OSes"
SRC_URI="http://swupdate.openvpn.net/community/releases/${P}.tar.gz
	test? ( https://raw.githubusercontent.com/OpenVPN/${PN}/v${PV}/tests/unit_tests/${PN}/mock_msg.h )"
HOMEPAGE="http://openvpn.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE="down-root examples inotify iproute2 libressl lz4 +lzo mbedtls pam"
IUSE+=" pkcs11 +plugins selinux +ssl static systemd test userland_BSD"

REQUIRED_USE="static? ( !plugins !pkcs11 )
	mbedtls? ( ssl !libressl )
	pkcs11? ( ssl )
	!plugins? ( !pam !down-root )
	inotify? ( plugins )"

CDEPEND="
	!net-misc/openvpn
	kernel_linux? (
		iproute2? ( sys-apps/iproute2[-minimal] )
		!iproute2? ( >=sys-apps/net-tools-1.60_p20160215155418 )
	)
	pam? ( virtual/pam )
	ssl? (
		!mbedtls? (
			!libressl? ( >=dev-libs/openssl-0.9.8:0= )
			libressl? ( dev-libs/libressl )
		)
		mbedtls? ( net-libs/mbedtls )
	)
	lz4? ( app-arch/lz4 )
	lzo? ( >=dev-libs/lzo-1.07 )
	pkcs11? ( >=dev-libs/pkcs11-helper-1.11 )
	systemd? ( sys-apps/systemd )"
DEPEND="${CDEPEND}
	test? ( dev-util/cmocka )"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-openvpn )"

CONFIG_CHECK="~TUN"

pkg_setup()  {
	linux-info_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-external-cmocka.patch"
	epatch "${FILESDIR}/${PN}-2.4.1-large-passwords.patch"
	epatch "${FILESDIR}/${PN}-2.4.1-pkcs11-slot.patch"
	epatch "${FILESDIR}/${PN}-2.4.1-redirect-gateway.patch"
	epatch "${FILESDIR}/${PN}-2.4.4-fix-illegal-client-float-CVE-2020-11810.patch"

	default
	eautoreconf

	if use test; then
		cp "${DISTDIR}/mock_msg.h" tests/unit_tests/${PN} || die
	fi
}

src_configure() {
	use static && append-ldflags -Xcompiler -static
	SYSTEMD_UNIT_DIR=$(systemd_get_systemunitdir) \
	TMPFILES_DIR="/usr/lib/tmpfiles.d" \
	IFCONFIG=/bin/ifconfig \
	ROUTE=/bin/route \
	econf \
		$(usex mbedtls '--with-crypto-library=mbedtls' '') \
		$(use_enable inotify async-push) \
		$(use_enable ssl crypto) \
		$(use_enable lz4) \
		$(use_enable lzo) \
		$(use_enable pkcs11) \
		$(use_enable plugins) \
		$(use_enable iproute2) \
		$(use_enable pam plugin-auth-pam) \
		$(use_enable down-root plugin-down-root) \
		$(use_enable test tests) \
		$(use_enable systemd)
}

src_test() {
	make check || die "top-level tests failed"
	pushd tests/unit_tests > /dev/null || die
	make check || die "unit tests failed"
	popd > /dev/null || die
}

src_install() {
	default
	find "${ED}/usr" -name '*.la' -delete
	# install documentation
	dodoc AUTHORS ChangeLog PORTS README README.IPv6

	# Install some helper scripts
	keepdir /etc/openvpn
	exeinto /etc/openvpn
	doexe "${FILESDIR}/up.sh"
	doexe "${FILESDIR}/down.sh"

	# Install the init script and config file
	newinitd "${FILESDIR}/${PN}-2.1.init" openvpn
	newconfd "${FILESDIR}/${PN}-2.1.conf" openvpn

	# install examples, controlled by the respective useflag
	if use examples ; then
		# dodoc does not supportly support directory traversal, #15193
		insinto /usr/share/doc/${PF}/examples
		doins -r sample contrib
	fi
}

pkg_postinst() {
	# Add openvpn user so openvpn servers can drop privs
	# Clients should run as root so they can change ip addresses,
	# dns information and other such things.
	enewgroup openvpn
	enewuser openvpn "" "" "" openvpn

	if grep -Eq "^[ \t]*(up|down)[ \t].*" "${ROOT}/etc/openvpn"/*.conf 2>/dev/null ; then
		ewarn ""
		ewarn "WARNING: If you use the remote keyword then you are deemed to be"
		ewarn "a client by our init script and as such we force up,down scripts."
		ewarn "These scripts call /etc/openvpn/\$SVCNAME-{up,down}.sh where you"
		ewarn "can move your scripts to."
	fi

	if use plugins ; then
		einfo ""
		einfo "plugins have been installed into /usr/$(get_libdir)/${PN}/plugins"
	fi
}
