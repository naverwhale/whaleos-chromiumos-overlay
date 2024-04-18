# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="3bffcf022fecd19d1a7548f5b5d31ded7ff504b2"
CROS_WORKON_TREE="27cf11abd13bfdb3ac0f787a58e82061bbb9f9e8"
CROS_WORKON_PROJECT="chromiumos/third_party/libva"
CROS_WORKON_MANUAL_UPREV="1"
CROS_WORKON_LOCALNAME="libva"
CROS_WORKON_EGIT_BRANCH="chromeos"

inherit autotools multilib-minimal cros-workon

DESCRIPTION="Video Acceleration (VA) API for Linux"
HOMEPAGE="https://01.org/linuxmedia/vaapi"
KEYWORDS="*"
LICENSE="MIT"
IUSE="utils"

VIDEO_CARDS="i965 amdgpu iHD"
for x in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${x}"
done

RDEPEND="
	>=x11-libs/libdrm-2.4.60[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"
PDEPEND="
	video_cards_i965? ( >=x11-libs/libva-intel-driver-2.0.0[${MULTILIB_USEDEP}] )
	video_cards_iHD? ( >=x11-libs/libva-intel-media-driver-23.2.4[${MULTILIB_USEDEP}] )
	video_cards_amdgpu? ( virtual/opengles[${MULTILIB_USEDEP}] )
	utils? ( media-video/libva-utils )
"

DOCS=( NEWS )

MULTILIB_WRAPPED_HEADERS=(
/usr/include/va/va_backend_glx.h
/usr/include/va/va_x11.h
/usr/include/va/va_dri2.h
/usr/include/va/va_dricommon.h
/usr/include/va/va_glx.h
)

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		--with-drivers-path="${EPREFIX}/usr/$(get_libdir)/va/drivers"
		--enable-drm
		--disable-x11
		--disable-glx
		--disable-wayland
		--enable-va-messaging
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install_all() {
	default
	find "${ED}" -type f -name "*.la" -delete || die
}
