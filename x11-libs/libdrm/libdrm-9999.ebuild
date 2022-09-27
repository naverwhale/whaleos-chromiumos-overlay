# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
EGIT_REPO_URI="https://gitlab.freedesktop.org/mesa/drm.git"
if [[ ${PV} != *9999* ]]; then
	CROS_WORKON_COMMIT="9cef5dee3cd817728c83aeb3c2010c1954e4c402"
	CROS_WORKON_TREE="25ac2f44628d93835f86f30b10d797a652f34cea"
fi
CROS_WORKON_PROJECT="chromiumos/third_party/libdrm"
CROS_WORKON_EGIT_BRANCH="upstream/master"
CROS_WORKON_MANUAL_UPREV="1"

inherit meson cros-workon

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
SRC_URI=""

# This package uses the MIT license inherited from Xorg but fails to provide
# any license file in its source, so we add X as a license, which lists all
# the Xorg copyright holders and allows license generation to pick them up.
LICENSE="|| ( MIT X )"
SLOT="0"
if [[ ${PV} = *9999* ]]; then
	KEYWORDS="~*"
else
	KEYWORDS="*"
fi
VIDEO_CARDS="amdgpu exynos freedreno intel nouveau omap radeon vc4 vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms manpages +udev"
REQUIRED_USE="video_cards_exynos? ( libkms )"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	udev? ( virtual/udev )
	video_cards_amdgpu? ( dev-util/cunit )
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )
	!<x11-libs/libdrm-tests-2.4.58-r3
"

DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/Add-header-for-Rockchip-DRM-userspace.patch
	eapply "${FILESDIR}"/Add-header-for-Mediatek-DRM-userspace.patch
	eapply "${FILESDIR}"/Add-Evdi-module-userspace-api-file.patch
	eapply "${FILESDIR}"/Add-Rockchip-AFBC-modifier.patch
	eapply "${FILESDIR}"/Add-back-VENDOR_NV-name.patch
	eapply "${FILESDIR}"/CHROMIUM-add-resource-info-header.patch

	eapply_user
}

src_configure() {
	cros_optimize_package_for_speed

	local emesonargs=(
		-Dinstall-test-programs=true
		$(meson_use video_cards_amdgpu amdgpu)
		$(meson_use video_cards_exynos exynos-experimental-api)
		$(meson_use video_cards_freedreno freedreno)
		$(meson_use video_cards_intel intel)
		$(meson_use video_cards_nouveau nouveau)
		$(meson_use video_cards_omap omap-experimental-api)
		$(meson_use video_cards_radeon radeon)
		$(meson_use video_cards_vc4 vc4)
		$(meson_use video_cards_vmware vmwgfx)
		$(meson_use libkms)
		$(meson_use manpages man-pages)
		$(meson_use udev)
		-Dcairo-tests=false
	)
	meson_src_configure
}
