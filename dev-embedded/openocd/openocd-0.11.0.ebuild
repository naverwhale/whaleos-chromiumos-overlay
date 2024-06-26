# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7
inherit autotools udev
if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="	https://repo.or.cz/openocd.git"
else
	MY_PV="${PV/_/-}"
	MY_P="${PN}-${MY_PV}"
	S="${WORKDIR}"/${MY_P}
	KEYWORDS="*"
	SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${MY_PV}/${MY_P}.tar.gz"
fi
DESCRIPTION="OpenOCD - Open On-Chip Debugger"
HOMEPAGE="http://openocd.sourceforge.net"
LICENSE="GPL-2+"
SLOT="0"
IUSE="capstone +cmsis-dap dummy +ftdi parport +usb verbose-io"
RESTRICT="strip" # includes non-native binaries
RDEPEND="
	acct-group/plugdev
	>=dev-lang/jimtcl-0.76:=
	<dev-lang/jimtcl-0.80:=
	capstone? ( dev-libs/capstone )
	cmsis-dap? ( dev-libs/hidapi )
	usb? ( virtual/libusb:1 )
	ftdi? ( dev-embedded/libftdi:= )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"
PATCHES=(
	"${FILESDIR}/5950-npcx.patch"
)
src_prepare() {
	default
	AT_NO_RECURSIVE=yes eautoreconf
}
src_configure() {
	local myconf=(
		--enable-amtjtagaccel
		--enable-arm-jtag-ew
		--enable-at91rm9200
		--enable-bcm2835gpio
		--enable-buspirate
		--enable-ep93xx
		--enable-gw16012
		--enable-jlink
		--enable-sysfsgpio
		--disable-internal-jimtcl
		--disable-werror
		$(use_with capstone)
		$(use_enable cmsis-dap)
		$(use_enable dummy)
		$(use_enable ftdi openjtag)
		$(use_enable ftdi presto)
		$(use_enable ftdi usb-blaster)
		$(use_enable parport)
		$(use_enable parport parport_ppdev)
		$(use_enable usb aice)
		--disable-armjtagew
		$(use_enable usb ftdi)
		$(use_enable usb osbdm)
		$(use_enable usb opendous)
		--disable-rlink
		$(use_enable usb stlink)
		$(use_enable usb ti-icdi)
		--disable-usbprog
		$(use_enable usb usb-blaster-2)
		$(use_enable usb ulink)
		$(use_enable usb vsllink)
		$(use_enable verbose-io verbose-jtag-io)
		$(use_enable verbose-io verbose-usb-io)
		$(use_enable verbose-io verbose_usb_comms)
	)
	econf "${myconf[@]}"
}
src_install() {
	default
	dostrip /usr/bin
	udev_dorules "${ED}"/usr/share/${PN}/contrib/*.rules
}
pkg_postinst() {
	elog "To access openocd devices as user you must be in the plugdev group"
}
