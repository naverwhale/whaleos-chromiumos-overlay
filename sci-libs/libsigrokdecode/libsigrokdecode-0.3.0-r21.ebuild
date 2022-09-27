# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/libsigrokdecode/libsigrokdecode-9999.ebuild,v 1.2 2014/06/14 06:09:26 vapier Exp $

EAPI="5"

CROS_WORKON_COMMIT="3279c2825684c7009775b731d0a9e37815778282"
CROS_WORKON_TREE="be143fb31be0ac7b9be8d1ae80513ea85a160384"
CROS_WORKON_PROJECT="chromiumos/third_party/libsigrokdecode"
CROS_WORKON_EGIT_BRANCH="chromeos"

PYTHON_COMPAT=( python3_{2,3,4,6} )
inherit cros-workon eutils python-single-r1 autotools

SRC_URI=""
KEYWORDS="*"

DESCRIPTION="provide (streaming) protocol decoding functionality"
HOMEPAGE="http://sigrok.org/wiki/Libsigrokdecode"

LICENSE="GPL-3"
SLOT="0"
IUSE="static-libs"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND=">=dev-libs/glib-2.24.0
	${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	[[ ${PV} == "9999" ]] && eautoreconf

	# Only a test program (not installed, and not used by src_test)
	# is used by libsigrok, so disable it to avoid the compile.
	sed -i \
		-e '/build_runtc=/s:yes:no:' \
		configure || die
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_test() {
	emake check
}

src_install() {
	default
	prune_libtool_files
}
