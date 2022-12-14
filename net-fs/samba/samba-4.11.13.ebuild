# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{6,7,8} )
PYTHON_REQ_USE='threads(+),xml(+)'

inherit python-single-r1 waf-utils multilib-minimal linux-info systemd pam

MY_PV="${PV/_rc/rc}"
MY_P="${PN}-${MY_PV}"

SRC_PATH="stable"
[[ ${PV} = *_rc* ]] && SRC_PATH="rc"

SRC_URI="mirror://samba/${SRC_PATH}/${MY_P}.tar.gz"
[[ ${PV} = *_rc* ]] || \
KEYWORDS="*"

DESCRIPTION="Samba Suite Version 4"
HOMEPAGE="https://www.samba.org/"
LICENSE="GPL-3"

SLOT="0"

IUSE="acl addc addns ads ceph client cluster cups debug dmapi fam gpg iprint
json ldap pam perl profiling-data python quota selinux snapper syslog
system-heimdal +system-mitkrb5 systemd test winbind zeroconf"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/samba-4.0/policy.h
	/usr/include/samba-4.0/dcerpc_server.h
	/usr/include/samba-4.0/ctdb.h
	/usr/include/samba-4.0/ctdb_client.h
	/usr/include/samba-4.0/ctdb_protocol.h
	/usr/include/samba-4.0/ctdb_private.h
	/usr/include/samba-4.0/ctdb_typesafe_cb.h
	/usr/include/samba-4.0/ctdb_version.h
)

# sys-apps/attr is an automagic dependency (see bug #489748)
CDEPEND="
	>=app-arch/libarchive-3.1.2[${MULTILIB_USEDEP}]
	perl? ( dev-lang/perl:= )
	dev-libs/libaio[${MULTILIB_USEDEP}]
	dev-libs/libbsd[${MULTILIB_USEDEP}]
	dev-libs/libgcrypt:0
	dev-libs/iniparser:0
	dev-libs/libtasn1[${MULTILIB_USEDEP}]
	dev-libs/popt[${MULTILIB_USEDEP}]
	python? ( $(python_gen_cond_dep 'dev-python/subunit[${PYTHON_USEDEP},'"${MULTILIB_USEDEP}"']') )
	>=dev-util/cmocka-1.1.1[${MULTILIB_USEDEP}]
	>=net-libs/gnutls-3.2.0[${MULTILIB_USEDEP}]
	net-libs/libnsl:=[${MULTILIB_USEDEP}]
	sys-apps/attr[${MULTILIB_USEDEP}]
	sys-libs/e2fsprogs-libs[${MULTILIB_USEDEP}]
	>=sys-libs/ldb-2.0.12[ldap(+)?,python?,${PYTHON_SINGLE_USEDEP},${MULTILIB_USEDEP}]
	<sys-libs/ldb-2.1.0[ldap(+)?,python?,${PYTHON_SINGLE_USEDEP},${MULTILIB_USEDEP}]
	sys-libs/libcap
	sys-libs/ncurses:0=
	sys-libs/readline:0=
	>=sys-libs/talloc-2.2.0[python?,${PYTHON_SINGLE_USEDEP},${MULTILIB_USEDEP}]
	>=sys-libs/tdb-1.4.2[python?,${PYTHON_SINGLE_USEDEP},${MULTILIB_USEDEP}]
	>=sys-libs/tevent-0.10.0[python?,${PYTHON_SINGLE_USEDEP},${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	virtual/libiconv
	pam? ( sys-libs/pam )
	acl? ( virtual/acl )
	addns? (
		net-dns/bind-tools[gssapi]
		$(python_gen_cond_dep 'dev-python/dnspython:=[${PYTHON_USEDEP}]')
	)
	ceph? ( sys-cluster/ceph )
	cluster? (
		net-libs/rpcsvc-proto
		!dev-db/ctdb
	)
	cups? ( net-print/cups )
	debug? ( dev-util/lttng-ust )
	dmapi? ( sys-apps/dmapi )
	fam? ( virtual/fam )
	gpg? ( app-crypt/gpgme )
	json? ( dev-libs/jansson )
	ldap? ( net-nds/openldap[${MULTILIB_USEDEP}] )
	snapper? ( sys-apps/dbus )
	system-heimdal? ( >=app-crypt/heimdal-1.5[-ssl,${MULTILIB_USEDEP}] )
	system-mitkrb5? ( >=app-crypt/mit-krb5-1.15.1[${MULTILIB_USEDEP}] )
	systemd? ( sys-apps/systemd:0= )
	zeroconf? ( net-dns/avahi )
"
DEPEND="${CDEPEND}
	${PYTHON_DEPS}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	net-libs/libtirpc[${MULTILIB_USEDEP}]
	virtual/pkgconfig
	|| (
		net-libs/rpcsvc-proto
		<sys-libs/glibc-2.26[rpc(+)]
	)
	test? (
		!system-mitkrb5? (
			>=sys-libs/nss_wrapper-1.1.3
			>=net-dns/resolv_wrapper-1.1.4
			>=net-libs/socket_wrapper-1.1.9
			>=sys-libs/uid_wrapper-1.2.1
		)
	)"
RDEPEND="${CDEPEND}
	python? ( ${PYTHON_DEPS} )
	client? ( net-fs/cifs-utils[ads?] )
	selinux? ( sec-policy/selinux-samba )
	!dev-perl/Parse-Yapp
"

REQUIRED_USE="
	addc? ( python json winbind )
	addns? ( python )
	ads? ( acl ldap winbind )
	cluster? ( ads )
	gpg? ( addc )
	python? ( ldap )
	test? ( python )
	?? ( system-heimdal system-mitkrb5 )
	${PYTHON_REQUIRED_USE}
"

# the test suite is messed, it uses system-installed samba
# bits instead of what was built, tests things disabled via use
# flags, and generally just fails to work in a way ebuilds could
# rely on in its current state
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/${PN}-4.4.0-pam.patch"
	"${FILESDIR}/${PN}-4.9.2-timespec.patch"
	"${FILESDIR}/${PN}-4.13-winexe_option.patch"
	"${FILESDIR}/${PN}-4.13-vfs_snapper_configure_option.patch"

	"${FILESDIR}/${PN}-4.11-async-dns-lookup.patch"
	"${FILESDIR}/${PN}-4.11-async-krb5-locator-plugin.patch"

	"${FILESDIR}/${PN}-4.11.13-machinepass_stdin.patch"
	"${FILESDIR}/${PN}-4.11.13-machinepass_expire.patch"
	"${FILESDIR}/${PN}-4.11.13-reuse_existing_computer_account.patch"

	# Temporary workaround until we fix Samba/OpenLDAP issues (see
	# https://crbug.com/953613).
	"${FILESDIR}/${PN}-4.11.13-lib-gpo-Cope-with-Site-GPO-s-list-failure.patch"

	# Apply latest security patches until 4.11.15 is available upstream.
	"${FILESDIR}/${PN}-4.11.14-security-2020-10-29.patch"

	# Backport glibc 2.32 nss.h naming conflict fix
	"${FILESDIR}/${PN}-4.11.13-fix-newer-glibc-nss-breakage.patch"
)

#CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"
CONFDIR="${FILESDIR}/4.4"

WAF_BINARY="${S}/buildtools/bin/waf"

SHAREDMODS=""

pkg_setup() {
	# Package fails to build with distcc
	export DISTCC_DISABLE=1

	python-single-r1_pkg_setup
	if use cluster ; then
		SHAREDMODS="idmap_rid,idmap_tdb2,idmap_ad"
	elif use ads ; then
		SHAREDMODS="idmap_ad"
	fi
}

src_prepare() {
	default

	# un-bundle dnspython
	sed -i -e '/"dns.resolver":/d' "${S}"/third_party/wscript || die

	# unbundle iso8601 unless tests are enabled
	if ! use test ; then
		sed -i -e '/"iso8601":/d' "${S}"/third_party/wscript || die
	fi

	# ugly hackaround for bug #592502
	cp "${SYSROOT}"/usr/include/tevent_internal.h "${S}"/lib/tevent/ || die

	sed -e 's:<gpgme\.h>:<gpgme/gpgme.h>:' \
		-i source4/dsdb/samdb/ldb_modules/password_hash.c \
		|| die

	# Friggin' WAF shit
	multilib_copy_sources
}

multilib_src_configure() {
	# when specifying libs for samba build you must append NONE to the end to
	# stop it automatically including things
	local bundled_libs="NONE"
	if ! use system-heimdal && ! use system-mitkrb5 ; then
		bundled_libs="heimbase,heimntlm,hdb,kdc,krb5,wind,gssapi,hcrypto,hx509,roken,asn1,com_err,NONE"
	fi

	local myconf=(
		--enable-fhs
		--sysconfdir="${EPREFIX}/etc"
		--localstatedir="${EPREFIX}/var"
		--with-modulesdir="${EPREFIX}/usr/$(get_libdir)/samba"
		--with-piddir="${EPREFIX}/run/${PN}"
		--bundled-libraries="${bundled_libs}"
		--builtin-libraries=NONE
		--disable-rpath
		--disable-rpath-install
		--nopyc
		--nopyo
		--without-winexe
		--without-regedit
		--with-libiconv="${SYSROOT}/usr"
		$(multilib_native_use_with acl acl-support)
		$(multilib_native_usex addc '' '--without-ad-dc')
		$(multilib_native_use_with addns dnsupdate)
		$(multilib_native_use_with ads)
		$(multilib_native_use_enable ceph cephfs)
		$(multilib_native_use_with cluster cluster-support)
		$(multilib_native_use_enable cups)
		$(multilib_native_use_with dmapi)
		$(multilib_native_use_with fam)
		$(multilib_native_use_with gpg gpgme)
		$(multilib_native_use_with json)
		$(multilib_native_use_enable iprint)
		$(multilib_native_use_with pam)
		$(multilib_native_usex pam "--with-pammodulesdir=${EPREFIX}/$(get_libdir)/security" '')
		$(multilib_native_use_with quota quotas)
		$(multilib_native_use_enable snapper)
		$(multilib_native_use_with syslog)
		$(multilib_native_use_with systemd)
		$(multilib_native_use_with winbind)
		$(multilib_native_usex python '' '--disable-python')
		$(multilib_native_use_enable zeroconf avahi)
		$(multilib_native_usex test '--enable-selftest' '')
		$(usex system-mitkrb5 "--with-system-mitkrb5 $(multilib_native_usex addc --with-experimental-mit-ad-dc '')" '')
		$(use_with debug lttng)
		$(use_with ldap)
		$(use_with profiling-data)
		# Gentoo bug #683148
		--jobs 1
	)

	multilib_is_native_abi && myconf+=( --with-shared-modules=${SHAREDMODS} )

	KRB5_CONFIG="${CHOST}-krb5-config" \
	CPPFLAGS="-I${SYSROOT}${EPREFIX}/usr/include/et ${CPPFLAGS}" \
		waf-utils_src_configure ${myconf[@]}
}

multilib_src_compile() {
	waf-utils_src_compile
}

multilib_src_install() {
	waf-utils_src_install

	# Make all .so files executable
	find "${ED}" -type f -name "*.so" -exec chmod +x {} + || die

	# Install async dns plugin only for amd64 architecture for authpolicyd and kerberosd
	if [[ "${ARCH}" == "amd64" ]]; then
		insinto "/usr/$(get_libdir)/krb5/plugins/libkrb5/"
		newins bin/default/nsswitch/libasync-dns-krb5-locator.inst.so libasync-dns-krb5-locator.so
	fi

	if multilib_is_native_abi ; then
		# install ldap schema for server (bug #491002)
		if use ldap ; then
			insinto /etc/openldap/schema
			doins examples/LDAP/samba.schema
		fi

		# create symlink for cups (bug #552310)
		if use cups ; then
			dosym ../../../bin/smbspool /usr/libexec/cups/backend/smb
		fi

		# install example config file
		insinto /etc/samba
		doins examples/smb.conf.default

		# Fix paths in example file (#603964)
		sed \
			-e '/log file =/s@/usr/local/samba/var/@/var/log/samba/@' \
			-e '/include =/s@/usr/local/samba/lib/@/etc/samba/@' \
			-e '/path =/s@/usr/local/samba/lib/@/var/lib/samba/@' \
			-e '/path =/s@/usr/local/samba/@/var/lib/samba/@' \
			-e '/path =/s@/usr/spool/samba@/var/spool/samba@' \
			-i "${ED%/}"/etc/samba/smb.conf.default || die

		# Install init script and conf.d file
		newinitd "${CONFDIR}/samba4.initd-r1" samba
		newconfd "${CONFDIR}/samba4.confd" samba

		systemd_dotmpfilesd "${FILESDIR}"/samba.conf
		systemd_dounit "${FILESDIR}"/nmbd.service
		systemd_dounit "${FILESDIR}"/smbd.{service,socket}
		systemd_newunit "${FILESDIR}"/smbd_at.service 'smbd@.service'
		systemd_dounit "${FILESDIR}"/winbindd.service
		systemd_dounit "${FILESDIR}"/samba.service
	fi

	if use pam && use winbind ; then
		newpamd "${CONFDIR}/system-auth-winbind.pam" system-auth-winbind
		# bugs #376853 and #590374
		insinto /etc/security
		doins examples/pam_winbind/pam_winbind.conf
	fi

	# Prune empty dirs to avoid tripping multilib checks.
	rmdir "${D}"/usr/lib* 2>/dev/null
}

multilib_src_install_all() {
	# Attempt to fix bug #673168
	find "${ED}" -type d -name "Yapp" -print0 \
		| xargs -0 --no-run-if-empty rm -r || die
}

multilib_src_test() {
	if multilib_is_native_abi ; then
		"${WAF_BINARY}" test || die "test failed"
	fi
}
