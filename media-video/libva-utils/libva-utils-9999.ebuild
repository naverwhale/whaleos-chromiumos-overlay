# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_PROJECT="chromiumos/third_party/libva-utils"
CROS_WORKON_MANUAL_UPREV="1"
CROS_WORKON_LOCALNAME="libva-utils"

inherit autotools flag-o-matic cros-workon

DESCRIPTION="Collection of utilities and tests for VA-API"
HOMEPAGE="https://01.org/linuxmedia/vaapi"
KEYWORDS="~*"

LICENSE="MIT"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
"
DEPEND="
	>=x11-libs/libva-2.0.0:=
	>=x11-libs/libdrm-2.4
"
RDEPEND="${DEPEND}"

# CONTRIBUTING.md and README.md are available only in .tar.gz tarballs and in git
DOCS=( NEWS CONTRIBUTING.md README.md )

src_prepare() {
	default
	sed -e 's/-Werror//' -i test/Makefile.am || die
	eautoreconf
}

src_configure() {
	# Building the tests needs its own TR1 library.
	append-cppflags "-DGTEST_USE_OWN_TR1_TUPLE=1"
	local myeconfargs=(
		--disable-x11
		--disable-wayland
		--enable-drm
		--enable-tests
		"$(use_enable test vendor_intel)"
	)
	econf "${myeconfargs[@]}"
}
