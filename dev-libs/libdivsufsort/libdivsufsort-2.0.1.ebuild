# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit cmake multilib

DESCRIPTION="Suffix-sorting library (for BWT)"
HOMEPAGE="https://github.com/y-256/libdivsufsort"
SRC_URI="https://github.com/y-256/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	cmake_src_prepare

	# will appreciate saner approach, if there is any
	sed -i -e "s:\(DESTINATION \)lib:\1$(get_libdir):" \
		*/CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=("-DBUILD_DIVSUFSORT64=ON")
	tc-export CC
	cmake_src_configure
}
