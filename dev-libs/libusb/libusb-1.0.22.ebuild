# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils ltprune toolchain-funcs multilib-minimal

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="https://libusb.info/ https://github.com/libusb/libusb"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="*"
IUSE="debug doc examples static-libs test udev"

RDEPEND="udev? ( >=virtual/libudev-208:=[${MULTILIB_USEDEP},static-libs?] )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	!udev? ( virtual/os-headers )"

src_prepare() {
	epatch "${FILESDIR}/0001-UPSTREAM-linux_usbfs-Fallback-to-usbfs-if-device-has.patch"
	epatch "${FILESDIR}/0002-UPSTREAM-linux_usbfs-Extract-device-handle-initializ.patch"
	epatch "${FILESDIR}/0003-UPSTREAM-linux_usbfs-Get-device-address-from-file-de.patch"
	epatch "${FILESDIR}/0004-UPSTREAM-core-Add-libusb_wrap_sys_device-API.patch"
	epatch "${FILESDIR}/0005-UPSTREAM-linux_usbfs-Implement-libusb_wrap_sys_devic.patch"
	epatch "${FILESDIR}/0006-CHROMIUM-linux_usbfs-tease-apart-linux_device_addres.patch"
	epatch "${FILESDIR}/0007-CHROMIUM-linux_usbfs-split-initialize_device.patch"
	epatch "${FILESDIR}/0008-CHROMIUM-linux_usbfs-wire-up-IOCTL_USBFS_CONNINFO_EX.patch"
	epatch "${FILESDIR}/0009-CHROMIUM-linux_usbfs-make-use-of-port-data-from-USBF.patch"
	epatch "${FILESDIR}/0010-CHROMIUM-linux_usbfs-parse-devpath-in-sysfs-to-get-p.patch"
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	econf \
		$(use_enable static-libs static) \
		$(use_enable udev) \
		$(use_enable debug debug-log) \
		$(use_enable test tests-build)
}

multilib_src_compile() {
	emake

	if multilib_is_native_abi; then
		use doc && emake -C doc docs
	fi
}

multilib_src_test() {
	emake check

	# noinst_PROGRAMS from tests/Makefile.am
	tests/stress || die
}

multilib_src_install() {
	emake DESTDIR="${D}" install

	if multilib_is_native_abi; then
		gen_usr_ldscript -a usb-1.0

		use doc && dodoc -r doc/html
	fi
}

multilib_src_install_all() {
	prune_libtool_files

	dodoc AUTHORS ChangeLog NEWS PORTING README TODO

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.{c,h}
		insinto /usr/share/doc/${PF}/examples/getopt
		doins examples/getopt/*.{c,h}
	fi
}
