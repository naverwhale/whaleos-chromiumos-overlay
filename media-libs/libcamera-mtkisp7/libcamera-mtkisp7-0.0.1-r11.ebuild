# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="3ae8a3f5c8d12204e130961a8d414c29374dcada"
CROS_WORKON_TREE="17866b14d0a929472ee70c3d762d9c078930c4ae"
CROS_WORKON_PROJECT="chromiumos/third_party/libcamera"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="libcamera/mtkisp7"
CROS_WORKON_EGIT_BRANCH="mtkisp7"

LIBCAMERA_PIPELINES="mtkisp7"

LIBCAMERA_DEPEND="
	media-libs/libcamera-tuning
	media-libs/mtk-isp7-3a-libs-bin
	media-libs/mtk-isp7-aie-firmware
	media-libs/mtk-isp7-hwcore
	media-libs/mtk-isp7-tuning-libs-bin
	"

inherit cros-camera cros-workon libcamera

DESCRIPTION="Camera support library for Linux on mtkisp7"

KEYWORDS="*"
