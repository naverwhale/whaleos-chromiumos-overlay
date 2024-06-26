# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{6..8} )
inherit cmake python-single-r1

MY_P="${PN}1-${PV}"
if [[ ${PV} == 9999* ]] ; then
	inherit git-r3
	EGIT_REPO_URI="git://developer.intra2net.com/${PN}"
else
	SRC_URI="http://www.intra2net.com/en/developer/${PN}/download/${MY_P}.tar.bz2"
	KEYWORDS="*"
fi

DESCRIPTION="Userspace access to FTDI USB interface chips"
HOMEPAGE="http://www.intra2net.com/en/developer/libftdi/"

LICENSE="LGPL-2"
SLOT="1"
IUSE="cxx doc examples python static-libs test tools"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="virtual/libusb:1
	cxx? ( dev-libs/boost )
	python? ( ${PYTHON_DEPS} )
	tools? (
		!<dev-embedded/ftdi_eeprom-1.0
		dev-libs/confuse
	)"
DEPEND="${RDEPEND}
	python? ( dev-lang/swig )
	doc? ( app-doc/doxygen )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

S=${WORKDIR}/${MY_P}

PATCHES=( "${FILESDIR}/${PN}-1.2-getopts.patch" )

src_configure() {
	local mycmakeargs=(
		-DFTDIPP=$(usex cxx)
		-DDOCUMENTATION=$(usex doc)
		-DEXAMPLES=$(usex examples)
		-DPYTHON_BINDINGS=$(usex python)
		-DSTATICLIBS=$(usex static-libs)
		-DBUILD_TESTS=$(usex test)
		-DFTDI_EEPROM=$(usex tools)
		-DCMAKE_SKIP_BUILD_RPATH=ON
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_optimize
	dodoc AUTHORS ChangeLog README TODO

	if use doc ; then
		# Clean up crap man pages. #356369
		rm -vf "${CMAKE_BUILD_DIR}"/doc/man/man3/_* || die

		doman "${CMAKE_BUILD_DIR}"/doc/man/man3/*
		dodoc -r "${CMAKE_BUILD_DIR}"/doc/html
	fi
	if use examples ; then
		docinto examples
		dodoc examples/*.c
	fi
	if use tools ; then
		insinto "/usr/share/${PN}"
		doins ${FILESDIR}/confs/*.conf
	fi
}
