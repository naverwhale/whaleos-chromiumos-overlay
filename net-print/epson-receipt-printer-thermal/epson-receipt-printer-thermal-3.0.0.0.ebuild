# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-sanitizers

DESCRIPTION="Epson Thermal Receipt Printer Driver"
HOMEPAGE="https://epson.com/Support/Point-of-Sale/Thermal-Printers/sh/s530"
SRC_URI="https://ftp.epson.com/drivers/pos/tmx-cups-src-ThermalReceipt-${PV}.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

BDEPEND="
	dev-util/cmake
"

# The tarball from upstream unpacks to 'Thermal Receipt'.  Instead of
# re-packaging the tarball, just set our build directory correctly.
S="${WORKDIR}/Thermal Receipt"

PATCHES=(
	"${FILESDIR}/${PN}-3.0.0.0-lfs-support.patch"
)

src_configure() {
	sanitizers-setup-env
}

src_compile() {
	./build.sh || die
}

src_install() {
	exeinto /usr/libexec/cups/filter
	doexe build/rastertotmtr
}
