# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "1f22ae3a4502e0dc175469f0df6450948deffc72" "94e1b450cb9db023fca27e8889078ff36c1eac15" "aac4fc3bcb2760b91a59046fcc144fd02380204f" "56d11be3eee2e1ae4822f70f73b6e8cc7a4082c8" "4e2e90590cddeed6a4ce5f763d6dcc6828c13fe6" "07fb7868e34e301a18d6f3035bc11f8714dee0ae" "f14a034a2f1490fbe098b88fae238497341d5ab0" "f7a3d73092dcec2f55cfbdaf263fbe773244cbd9" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "cceb75d9e5555d3cccb273c52847819feabc9c65")
SUBTREES=(
	.gn
	camera/build
	camera/common
	camera/features
	camera/gpu
	# TODO(crbug.com/914263): camera/hal is unnecessary for this build but
	# is workaround for unexpected sandbox behavior.
	camera/hal
	camera/hal_adapter
	camera/include
	camera/mojo
	common-mk
	ml_core
)

CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="${SUBTREES[*]}"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/hal_adapter"

inherit cros-camera cros-constants cros-workon platform tmpfiles user udev

DESCRIPTION="ChromeOS camera service. The service is in charge of accessing
camera device. It uses unix domain socket to build a synchronous channel."

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cheets camera_feature_face_detection camera_feature_diagnostics arcvm -libcamera"

BDEPEND="virtual/pkgconfig"

RDEPEND="
	>=chromeos-base/cros-camera-libs-0.0.1-r34:=
	chromeos-base/cros-camera-android-deps:=
	chromeos-base/system_api:=
	media-libs/cros-camera-hal-usb:=
	media-libs/libsync:=
	media-libs/libyuv:=
	libcamera? ( media-libs/libcamera )
	!libcamera? (
		virtual/cros-camera-hal
		virtual/cros-camera-hal-configs
	)"

DEPEND="${RDEPEND}
	chromeos-base/dlcservice-client:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	media-libs/minigbm:=
	x11-drivers/opengles-headers:=
	x11-libs/libdrm:="


BDEPEND="
	chromeos-base/minijail
"

src_configure() {
	cros_optimize_package_for_speed
	platform_src_configure
}

src_install() {
	platform_src_install
	udev_dorules udev/99-camera.rules
	dotmpfiles tmpfiles.d/*.conf
}

pkg_preinst() {
	enewuser "arc-camera"
	enewgroup "arc-camera"
	enewgroup "camera"
}
