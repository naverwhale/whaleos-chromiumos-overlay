# Copyright 2010 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib

DESCRIPTION="An image comparison utility"
HOMEPAGE="http://pdiff.sourceforge.net/"
SRC_URI="mirror://sourceforge/pdiff/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="media-libs/freeimage"
RDEPEND="${DEPEND}"

DOCS="gpl.txt README.txt"

S=${WORKDIR}

PATCHES=(
	"${FILESDIR}"/CMakeFiles-search-in-SYSROOT.patch
	"${FILESDIR}"/Metric.cpp-printf-needs-stdio.patch
)

src_prepare() {
	default
	# Use the correct ABI lib dir.
	sed -i \
		-e "s:/lib$:/$(get_libdir):" \
		CMakeLists.txt || die
}

src_configure() {
	tc-export CC CXX AR RANLIB LD NM
	cmake . || die cmake failed
}

src_install() {
	dobin perceptualdiff
}
