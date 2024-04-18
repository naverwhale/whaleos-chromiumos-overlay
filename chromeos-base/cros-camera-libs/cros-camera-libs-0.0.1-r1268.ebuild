# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "1f22ae3a4502e0dc175469f0df6450948deffc72" "94e1b450cb9db023fca27e8889078ff36c1eac15" "aac4fc3bcb2760b91a59046fcc144fd02380204f" "56d11be3eee2e1ae4822f70f73b6e8cc7a4082c8" "f14a034a2f1490fbe098b88fae238497341d5ab0" "f7a3d73092dcec2f55cfbdaf263fbe773244cbd9" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "1e601fb1df98e9ea9f5803aeb50bd6fbec835a2a" "e40ac435946a5417104d844a323350d04e9d3b2e" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "cceb75d9e5555d3cccb273c52847819feabc9c65" "05a052ec9a484e721478c7bb3e5e8e76c4ddc016")
SUBTREES=(
	.gn
	camera/build
	camera/common
	camera/features
	camera/gpu
	camera/include
	camera/mojo
	chromeos-config
	common-mk
	iioservice/libiioservice_ipc
	iioservice/mojo
	metrics
	ml_core
	mojo_service_manager
)

CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="${SUBTREES[*]}"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common"

inherit cros-camera cros-constants cros-workon platform

DESCRIPTION="ChromeOS camera common libraries."

LICENSE="BSD-Google"
KEYWORDS="*"

CAMERA_FEATURE_PREFIX="camera_feature_"
IUSE_FEATURE_FLAGS=(
	auto_framing
	diagnostics
	effects
	face_detection
	frame_annotator
	hdrnet
	portrait_mode
)
IUSE_PLATFORM_FLAGS=(
	ipu6
	ipu6ep
	ipu6epadln
	ipu6epmtl
	ipu6se
	qualcomm_camx
)

# FEATURE and PLATFORM IUSE flags are passed to and used in BUILD.gn files.
IUSE="
	${IUSE_FEATURE_FLAGS[*]/#/${CAMERA_FEATURE_PREFIX}}
	${IUSE_PLATFORM_FLAGS[*]}
"

BDEPEND="
	chromeos-base/minijail
	virtual/pkgconfig
"

RDEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/cros-camera-android-deps:=
	chromeos-base/mojo_service_manager:=
	camera_feature_effects? ( dev-libs/ml-core:= )
	dev-libs/re2:=
	media-libs/cros-camera-libfs:=
	media-libs/libexif:=
	media-libs/libsync:=
	media-libs/minigbm:=
	virtual/jpeg:0=
	virtual/libudev:=
	virtual/opengles:=
	x11-libs/libdrm:=
"

DEPEND="
	${RDEPEND}
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/system_api:=
	media-libs/cros-camera-libcamera_connector_headers:=
	media-libs/libyuv:=
	x11-base/xorg-proto:=
	x11-drivers/opengles-headers:=
"

src_configure() {
	cros_optimize_package_for_speed
	platform_src_configure
}

src_install() {
	local fuzzer_component_id="167281"
	platform_fuzzer_install "${S}"/OWNERS \
			"${OUT}"/camera_still_capture_processor_impl_fuzzer \
			--comp "${fuzzer_component_id}"
	platform_src_install
}

platform_pkg_test() {
	platform test_all
}
