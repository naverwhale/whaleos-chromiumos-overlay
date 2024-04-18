# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-constants
CROS_WORKON_REPO=(
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_INT_HOST_URL}"
)
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/libva-intel-media-driver"
	"chromeos/vendor/intel-ihd-pavp"
)
CROS_WORKON_LOCALNAME=(
	"libva-intel-media-driver"
	"../partner_private/intel-ihd-pavp"
)
CROS_WORKON_EGIT_BRANCH=(
	"chromeos"
	"main"
)
CROS_WORKON_OPTIONAL_CHECKOUT=(
	"true"
	"use intel_oemcrypto && (use internal || use intel_ihd_pavp)"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/pavp"
)
CROS_WORKON_MANUAL_UPREV="1"

inherit cmake cros-workon

KEYWORDS="~*"
DESCRIPTION="Intel Media Driver for VAAPI (iHD)"
HOMEPAGE="https://github.com/intel/media-driver"

LICENSE="
	intel_oemcrypto? ( internal? ( LICENSE.intel-pavp ) )
	intel_oemcrypto? ( !internal? ( intel_ihd_pavp? ( LICENSE.intel-pavp ) ) )
	intel_oemcrypto? ( !internal? ( !intel_ihd_pavp? ( MIT BSD ) ) )
	!intel_oemcrypto? ( MIT BSD )
"
SLOT="0"
IUSE="ihd_cmrtlib intel_oemcrypto intel_ihd_pavp internal video_cards_iHD_g8 video_cards_iHD_g9 video_cards_iHD_g11 video_cards_iHD_g12"
REQUIRED_USE="|| ( video_cards_iHD_g8 video_cards_iHD_g9 video_cards_iHD_g11 video_cards_iHD_g12 )"

DEPEND=">=media-libs/gmmlib-22.3.7:=
	>=x11-libs/libva-2.19.0
"
RDEPEND="${DEPEND}"

src_prepare() {
	use intel_oemcrypto && (use internal || use intel_ihd_pavp) && PATCHES+=( pavp/patches/*.patch )
	cmake_src_prepare
}

src_configure() {
	cros_optimize_package_for_speed
	local mycmakeargs=(
		-DMEDIA_RUN_TEST_SUITE=OFF
		-DBUILD_TYPE=Release
		-DPLATFORM=linux
		-DCMAKE_DISABLE_FIND_PACKAGE_X11=TRUE
		-DBUILD_CMRTLIB=$(usex ihd_cmrtlib ON OFF)

		-DGEN8=$(usex video_cards_iHD_g8 ON OFF)
		-DGEN9=$(usex video_cards_iHD_g9 ON OFF)
		-DGEN10=OFF
		-DGEN11=$(usex video_cards_iHD_g11 ON OFF)
		-DGEN12=$(usex video_cards_iHD_g12 ON OFF)
	)
	local CMAKE_BUILD_TYPE="Release"
	cmake_src_configure
}
