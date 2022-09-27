# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/flashrom/flashrom-0.9.4.ebuild,v 1.5 2011/09/20 16:03:21 nativemad Exp $

EAPI=7
CROS_WORKON_COMMIT="1e7280e4d08c8cd0a085cae9e35e81572f5cfb4d"
CROS_WORKON_TREE="e6e4d98da97a629bd52a2611cca5b67f73230dbb"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"
CROS_WORKON_EGIT_BRANCH="master"

inherit cros-workon toolchain-funcs meson

DESCRIPTION="Utility for reading, writing, erasing and verifying flash ROM chips"
HOMEPAGE="https://flashrom.org/"
#SRC_URI="http://download.flashrom.org/releases/${P}.tar.bz2"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE="
	atahpt
	atapromise
	+atavia
	+buspirate_spi
	+ch341a_spi
	dediprog
	+developerbox_spi
	+digilent_spi
	+drkaiser
	+dummy
	ene_lpc
	+ft2232_spi
	+gfxnvidia
	+internal
	+it8212
	jlink_spi
	+linux_mtd
	+linux_spi
	+lspcon_i2c_spi
	mec1308
	mstarddc_spi
	+nic3com
	+nicintel
	+nicintel_eeprom
	+nicintel_spi
	+nicnatsemi
	+nicrealtek
	+ogp_spi
	+pickit2_spi
	+pony_spi
	+raiden_debug_spi
	+rayer_spi
	+realtek_mst_i2c_spi
	+satasii
	+satamv
	+serprog static
	+stlinkv3_spi
	test
	+usbblaster_spi
	+wiki
"

LIB_DEPEND="
	atahpt? ( sys-apps/pciutils[static-libs(+)] )
	atapromise? ( sys-apps/pciutils[static-libs(+)] )
	atavia? ( sys-apps/pciutils[static-libs(+)] )
	ch341a_spi? ( virtual/libusb:1[static-libs(+)] )
	dediprog? ( virtual/libusb:1[static-libs(+)] )
	developerbox_spi? ( virtual/libusb:1[static-libs(+)] )
	digilent_spi? ( virtual/libusb:1[static-libs(+)] )
	drkaiser? ( sys-apps/pciutils[static-libs(+)] )
	ft2232_spi? ( dev-embedded/libftdi:=[static-libs(+)] )
	gfxnvidia? ( sys-apps/pciutils[static-libs(+)] )
	internal? ( sys-apps/pciutils[static-libs(+)] )
	it8212? ( sys-apps/pciutils[static-libs(+)] )
	jlink_spi? ( dev-embedded/libjaylink[static-libs(+)] )
	nic3com? ( sys-apps/pciutils[static-libs(+)] )
	nicintel_eeprom? ( sys-apps/pciutils[static-libs(+)] )
	nicintel_spi? ( sys-apps/pciutils[static-libs(+)] )
	nicintel? ( sys-apps/pciutils[static-libs(+)] )
	nicnatsemi? ( sys-apps/pciutils[static-libs(+)] )
	nicrealtek? ( sys-apps/pciutils[static-libs(+)] )
	raiden_debug_spi? ( virtual/libusb:1[static-libs(+)] )
	ogp_spi? ( sys-apps/pciutils[static-libs(+)] )
	pickit2_spi? ( virtual/libusb:0[static-libs(+)] )
	rayer_spi? ( sys-apps/pciutils[static-libs(+)] )
	satamv? ( sys-apps/pciutils[static-libs(+)] )
	satasii? ( sys-apps/pciutils[static-libs(+)] )
	stlinkv3_spi? ( virtual/libusb:1[static-libs(+)] )
	usbblaster_spi? ( dev-embedded/libftdi:1=[static-libs(+)] )
"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
	test? ( dev-util/cmocka )"
RDEPEND+=" internal? ( sys-apps/dmidecode )"

BDEPEND="sys-apps/diffutils"

DOCS=( README.chromiumos Documentation/ )

src_configure() {
	local emesonargs=(
		-Ddefault_library="$(usex static static shared)"
		-Ddefault_programmer_name=internal
		$(meson_use atahpt config_atahpt)
		$(meson_use atapromise config_atapromise)
		$(meson_use atavia config_atavia)
		$(meson_use buspirate_spi config_buspirate_spi)
		$(meson_use ch341a_spi config_ch341a_spi)
		$(meson_use dediprog config_dediprog)
		$(meson_use developerbox_spi config_developerbox_spi)
		$(meson_use digilent_spi config_digilent_spi)
		$(meson_use drkaiser config_drkaiser)
		$(meson_use dummy config_dummy)
		$(meson_use ene_lpc config_ene_lpc)
		$(meson_use ft2232_spi config_ft2232_spi)
		$(meson_use gfxnvidia config_gfxnvidia)
		$(meson_use internal config_internal)
		$(meson_use it8212 config_it8212)
		$(meson_use jlink_spi config_jlink_spi)
		$(meson_use linux_mtd config_linux_mtd)
		$(meson_use linux_spi config_linux_spi)
		$(meson_use lspcon_i2c_spi config_lspcon_i2c_spi)
		$(meson_use mec1308 config_mec1308)
		$(meson_use mstarddc_spi config_mstarddc_spi)
		$(meson_use nic3com config_nic3com)
		$(meson_use nicintel_eeprom config_nicintel_eeprom)
		$(meson_use nicintel_spi config_nicintel_spi)
		$(meson_use nicintel config_nicintel)
		$(meson_use nicnatsemi config_nicnatsemi)
		$(meson_use nicrealtek config_nicrealtek)
		$(meson_use ogp_spi config_ogp_spi)
		$(meson_use pickit2_spi config_pickit2_spi)
		$(meson_use pony_spi config_pony_spi)
		$(meson_use raiden_debug_spi config_raiden_debug_spi)
		$(meson_use rayer_spi config_rayer_spi)
		$(meson_use realtek_mst_i2c_spi config_realtek_mst_i2c_spi)
		$(meson_use satamv config_satamv)
		$(meson_use satasii config_satasii)
		$(meson_use serprog config_serprog)
		$(meson_use stlinkv3_spi config_stlinkv3_spi)
		$(meson_use usbblaster_spi config_usbblaster_spi)
		$(meson_use wiki print_wiki)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}

src_test() {
	meson_src_test
}
