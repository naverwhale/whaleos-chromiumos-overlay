# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# shellcheck disable=SC2034
QA_PKGCONFIG_VERSION="$(ver_cut 1-3)"

inherit autotools multilib-minimal libtool flag-o-matic

MY_P="${P/_rc/rc}"
DESCRIPTION="Tag Image File Format (TIFF) library"
HOMEPAGE="http://libtiff.maptools.org"
SRC_URI="https://download.osgeo.org/libtiff/${MY_P}.tar.xz"
SRC_URI+=" verify-sig? ( https://download.osgeo.org/libtiff/${MY_P}.tar.xz.sig )"
S="${WORKDIR}/${PN}-$(ver_cut 1-3)"

LICENSE="libtiff"
SLOT="0/6"
if [[ ${PV} != *_rc* ]] ; then
	KEYWORDS="*"
fi
IUSE="cros_host +cxx jbig jpeg lzma static-libs test verify-sig webp zlib zstd"
RESTRICT="!test? ( test )"

# bug #483132
REQUIRED_USE="test? ( jpeg )"

RDEPEND="
	jbig? ( >=media-libs/jbigkit-2.1:=[${MULTILIB_USEDEP}] )
	jpeg? ( media-libs/libjpeg-turbo:=[${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1[${MULTILIB_USEDEP}] )
	webp? ( media-libs/libwebp:=[${MULTILIB_USEDEP}] )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )
	zstd? ( >=app-arch/zstd-1.3.7-r1:=[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="verify-sig? ( sec-keys/openpgp-keys-evenrouault )"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/tiffconf.h
)

PATCHES=(
)

src_prepare() {
	default

	# Added to fix cross-compilation
	elibtoolize
}

multilib_src_configure() {
	append-lfs-flags

	local myeconfargs=(
		--disable-sphinx
		--without-x
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF}
		$(use_enable cxx)
		$(use_enable jbig)
		$(use_enable jpeg)
		$(use_enable lzma)
		$(use_enable static-libs static)
		$(use_enable test tests)
		$(use_enable webp)
		$(use_enable zlib)
		$(use_enable zstd)
		--disable-docs
		--disable-contrib
		"$(multilib_native_enable tools)"
	)

	# ChromeOS: install utilities to /usr/local unless installing to the SDK.
	if ! use cros_host ; then
		myeconfargs+=( --bindir="${EPREFIX}/usr/local/bin" )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	find "${ED}" -type f -name '*.la' -delete || die
	rm -f "${ED}"/usr/share/doc/${PF}/{README*,RELEASE-DATE,TODO,VERSION} || die
}
