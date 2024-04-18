# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic autotools multilib-minimal systemd toolchain-funcs udev \
	user cros-sanitizers strip-linguas

# gphoto and v4l are handled by their usual USE flags.
# The pint backend was disabled because I could not get it to compile.
IUSE_SANE_BACKENDS="
	abaton
	agfafocus
	apple
	artec
	artec_eplus48u
	as6e
	avision
	bh
	canon
	canon630u
	canon_dr
	canon_lide70
	canon_pp
	cardscan
	coolscan
	coolscan2
	coolscan3
	dc210
	dc240
	dc25
	dell1600n_net
	dmc
	epjitsu
	epson
	epson2
	epsonds
	escl
	fujitsu
	genesys
	gt68xx
	hp
	hp3500
	hp3900
	hp4200
	hp5400
	hp5590
	hpljm1005
	hpsj5s
	hs2p
	ibm
	kodak
	kodakaio
	kvs1025
	kvs20xx
	kvs40xx
	leo
	lexmark
	ma1509
	magicolor
	matsushita
	microtek
	microtek2
	mustek
	mustek_pp
	mustek_usb
	mustek_usb2
	nec
	net
	niash
	p5
	pie
	pixma
	plustek
	plustek_pp
	pnm
	qcam
	ricoh
	ricoh2
	rts8891
	s9036
	sceptre
	sharp
	sm3600
	sm3840
	snapscan
	sp15c
	st400
	stv680
	tamarack
	teco1
	teco2
	teco3
	test
	u12
	umax
	umax1220u
	umax_pp
	xerox_mfp"

IUSE="gphoto2 ipv6 snmp systemd threads usb v4l xinetd zeroconf"

for backend in ${IUSE_SANE_BACKENDS}; do
	# Disable all backends by default, explicitly enabled in package.use
	IUSE+=" -sane_backends_${backend}"
done

REQUIRED_USE="
	sane_backends_mustek_usb2? ( threads )
	sane_backends_kvs40xx? ( threads )
"

DESCRIPTION="Scanner Access Now Easy - Backends"
HOMEPAGE="http://www.sane-project.org/"
SRC_URI="https://gitlab.com/sane-project/backends/-/archive/${PV}/backends-${PV}.tar.gz -> sane-backends-1.2.1.tar.gz"
S="${WORKDIR}/sane-backends-${PV}"

LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=media-gfx/sane-backends-1.2.1-r7[${MULTILIB_USEDEP}]
	sane_backends_dc210? ( >=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}] )
	sane_backends_dc240? ( >=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}] )
	>=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}]
	>=media-libs/tiff-3.9.7-r1:0=[${MULTILIB_USEDEP}]
	sane_backends_canon_pp? ( >=sys-libs/libieee1284-0.2.11-r3[${MULTILIB_USEDEP}] )
	sane_backends_hpsj5s? ( >=sys-libs/libieee1284-0.2.11-r3[${MULTILIB_USEDEP}] )
	sane_backends_mustek_pp? ( >=sys-libs/libieee1284-0.2.11-r3[${MULTILIB_USEDEP}] )
	usb? ( >=virtual/libusb-1-r1:1=[${MULTILIB_USEDEP}] )
	gphoto2? (
		>=media-libs/libgphoto2-2.5.3.1:=[${MULTILIB_USEDEP}]
		>=virtual/jpeg-0-r2:0=[${MULTILIB_USEDEP}]
	)
	v4l? ( >=media-libs/libv4l-0.9.5[${MULTILIB_USEDEP}] )
	xinetd? ( sys-apps/xinetd )
	snmp? ( net-analyzer/net-snmp:0= )
	systemd? ( sys-apps/systemd:0= )
	zeroconf? ( >=net-dns/avahi-0.6.31-r2[${MULTILIB_USEDEP}] )
"

DEPEND="${RDEPEND}
	v4l? ( sys-kernel/linux-headers )
	>=sys-devel/gettext-0.18.1
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
"

BDEPEND="
	sys-devel/autoconf-archive
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/sane-config
)

src_prepare() {
	default

	cat >> backend/dll.conf.in <<-EOF
	# Add support for the HP-specific backend.	Needs net-print/hplip installed.
	hpaio
	# Add support for the Epson-specific backend.  Needs media-gfx/iscan installed.
	epkowa
	EOF

	eapply "${FILESDIR}"/sane-backends-1.2.1-dlc.patch
	eapply "${FILESDIR}"/sane-backends-1.2.1-epsonds.patch
	eapply "${FILESDIR}"/sane-backends-1.0.24-saned_pidfile_location.patch
	eapply "${FILESDIR}"/${PN}-1.2.1-remove-redundancies.patch

	# From Arch
	eapply "${FILESDIR}"/sane-backends-1.0.30-network.patch

	# Upstream sometimes forgets to remove the "git describe" check
	# in the version, which then fails because .git isn't included in the
	# released tarball.  Replace it with the plain version number.
	sed -i \
		-e "s/^\(AC_INIT([^,]*,\)m4_esyscmd_s([^)]*),/\1${PV},/" \
		configure.ac || die
	eautoreconf

	# Fix for "make check".  Upstream sometimes forgets to update this.
	local ver=$(./configure --version | awk '{print $NF; exit 0}')
	sed -i \
		-e "/by sane-desc 3.5 from sane-backends/s:sane-backends .*:sane-backends ${ver}:" \
		testsuite/tools/data/html* || die
}

src_configure() {
	# Sanitizers don't link properly, but we want to fuzz dependent
	# packages (b/160181793).
	filter_sanitizers

	# genesys backend doesn't build without exceptions.
	cros_enable_cxx_exceptions
	append-flags -fno-strict-aliasing # From Fedora
	append-lfs-flags

	# enable link-time optimization to reduce size of genesys backend ~20%.
	append-flags -flto
	append-ldflags -flto

	# if LINGUAS is set, just use the listed and supported localizations.
	# shellcheck disable=SC2154
	if [[ "${LINGUAS+set}" == "set" ]]; then
		mkdir -p po || die
		strip-linguas -u po
		printf '%s\n' "${LINGUAS}" > po/LINGUAS
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	# the blank is intended - an empty string would result in building ALL backends.
	local BACKENDS=" "

	use gphoto2 && BACKENDS="gphoto2"
	use v4l && BACKENDS="${BACKENDS} v4l"
	for backend in ${IUSE_SANE_BACKENDS}; do
		if use "sane_backends_${backend}" && [ "${backend}" != pnm ]; then
			BACKENDS="${BACKENDS} ${backend}"
		fi
	done

	local myconf=(
		"$(use_with usb)"
		"$(multilib_native_use_with snmp)"
	)

	# you can only enable this backend, not disable it...
	if use sane_backends_pnm; then
		myconf+=( --enable-pnm-backend )
	fi
	if use sane_backends_mustek_pp; then
		myconf+=( --enable-parport-directio )
	fi
	if ! { use sane_backends_canon_pp || use sane_backends_hpsj5s || use sane_backends_mustek_pp; }; then
		myconf+=( sane_cv_use_libieee1284=no )
	fi

	# relative path must be used for tests to work properly
	# All distributions pass --disable-locking because /var/lock/sane/ would be a world-writable directory
	ECONF_SOURCE=${S} \
	SANEI_JPEG="sanei_jpeg.o" SANEI_JPEG_LO="sanei_jpeg.lo" \
	BACKENDS="${BACKENDS}" \
	econf \
		--disable-locking \
		"$(use_with gphoto2)" \
		"$(multilib_native_use_with systemd)" \
		"$(use_with v4l)" \
		"$(use_enable ipv6)" \
		"$(use_enable threads pthread)" \
		"$(use_with zeroconf avahi)" \
		"${myconf[@]}"
}

multilib_src_install_all() {
	dodoc NEWS AUTHORS ChangeLog ChangeLogs/* PROBLEMS README README.linux
	find "${D}" -name '*.la' -delete || die

	# Delete collisions files if they exist since they already exist from the main ebuild
	local sane_lib_dir="${ED}/usr/$(get_libdir)"
	local shared_lib_names="
			libsane.so
			libsane.so.$(ver_cut 1 ${PV})
			libsane.so.${PV}
			sane/libsane-dll.so
			sane/libsane-dll.so.$(ver_cut 1 ${PV})
			sane/libsane-dll.so.${PV}
	"
	for lib in ${shared_lib_names}; do
			rm "${sane_lib_dir}/${lib}"
	done
	rm "${ED}/usr/bin/x86_64-cros-linux-gnu-sane-config"
	rm "${ED}/usr/bin/armv7a-cros-linux-gnueabihf-sane-config"
	rm "${ED}/usr/bin/aarch64-cros-linux-gnu-sane-config"
	rm "${ED}/usr/bin/sane-config"
	rm "${ED}/usr/include/sane/sane.h"
	rm "${ED}/usr/include/sane/saneopts.h"

}
