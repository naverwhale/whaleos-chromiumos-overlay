# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform/libva-fake-driver"
CROS_WORKON_PROJECT="chromiumos/platform/libva-fake-driver"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-common.mk

DESCRIPTION="Chrome OS fake LibVA driver; intended as a backend replacement for VMs and other test fixtures"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/libva-fake-driver/ "

LICENSE="BSD-Google"
KEYWORDS="~*"

RDEPEND=">=x11-libs/libva-2.6.0:="
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	dolib.so "${OUT}"/fake_drv_video.so

	# Needs to be visible from /usr/lib64/va/drivers/
	dosym /usr/$(get_libdir)/fake_drv_video.so /usr/$(get_libdir)/va/drivers/fake_drv_video.so
}
