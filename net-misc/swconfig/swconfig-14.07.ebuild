# Copyright 2015 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

# Note: the source tarball was created this way:
#   $ git clone git://git.openwrt.org/14.07/openwrt.git openwrt-14.07
#   (HEAD SHA1 is 3a2fa0047498d1f7521113f7fe7e16dda8ea4452)
#   $ tar -zcf swconfig-14.07.tar.gz -C openwrt-14.07/package/network/config/swconfig .

EAPI="4"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="swconfig utility used to configure home switch devices"
HOMEPAGE="http://wiki.openwrt.org/doc/techref/swconfig"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-libs/libnl:3"
DEPEND="${RDEPEND}"

S=${WORKDIR}/src

src_prepare() {
	epatch "${FILESDIR}/${P}-use-pkg-config.patch"
	epatch "${FILESDIR}/${P}-remove_uci_dependencies.patch"
	epatch "${FILESDIR}/${P}-rename-switch-h.patch"

	# install linux/switchdev.h
	cp -r "${FILESDIR}/${P}-uapi-linux" "${S}/linux"|| die
	append-cflags "-I${S}"
}

src_configure() {
	tc-export CC PKG_CONFIG
}

src_install() {
	dosbin swconfig
}
