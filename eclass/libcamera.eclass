# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: libcamera.eclass
# @MAINTAINER: ChromiumOS libcamera team <chromeos-libcamera-eng@google.com>
# @SUPPORTED_EAPIS: 7+
# @BLURB: helper eclass for shared dependencies and args of libcamera builds
# @DESCRIPTION:
# Most of code to build libcamera (for different camera modules) are the same.
# Thus, this eclass is used to save duplicated code. Ebuild that inherits this
# eclass should provide LIBCAMERA_DEPEND that the camera module needs
# individually, and LIBCAMERA_PIPELINES to be used.

if [[ -z ${_LIBCAMERA_ECLASS} ]]; then
_LIBCAMERA_ECLASS=1

# Check for EAPI 7+.
case "${EAPI:-0}" in
[0123456]) die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}" ;;
esac

inherit meson

HOMEPAGE="https://www.libcamera.org"
LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="debug dev doc test udev"

# @ECLASS-VARIABLE: LIBCAMERA_PIPELINES
# @DESCRIPTION:
# A list of pipelines enabled. If set to "auto", all pipelines supported in the
# architectures will be enabled. If set to "all", all pipelines will be
# enabled.
: "${LIBCAMERA_PIPELINES:=}"

# @ECLASS-VARIABLE: LIBCAMERA_DEPEND
# @DESCRIPTION:
# A list of dependencies needed for pipelines enabled.
: "${LIBCAMERA_DEPEND:=}"

RDEPEND="
	${LIBCAMERA_DEPEND}
	chromeos-base/cros-camera-libs:=
	dev? ( dev-libs/libevent[threads] )
	dev-libs/libyaml:=
	media-libs/libcamera-configs:=
	media-libs/libjpeg-turbo:=
	media-libs/libexif:=
	>=net-libs/gnutls-3.3:=
	media-libs/libyuv:=
	udev? ( virtual/libudev:= )
	virtual/libelf:=
"

DEPEND="${RDEPEND}"

# openssl is only needed in build time to sign IPA modules:
# https://libcamera.org/getting-started.html
# pyyaml is also only needed in build time for python scripts.
BDEPEND="
	dev-libs/openssl
	>=dev-python/pyyaml-3
"

libcamera_src_configure() {
	# By default Chrome OS build system adds the CFLAGS/CXXFLAGS
	# -fno-unwind-tables and -fno-asynchronous-unwind-table as part of
	# disabling exception support. This prevents unwinding of stack frames to
	# show backtrace. Calling 'cros_enable_cxx_exceptions' to remove those
	# flags when debugging is enabled.
	use debug && cros_enable_cxx_exceptions

	BUILD_DIR="$(cros-workon_get_build_dir)"

	local emesonargs=(
		$(meson_use test)
		$(meson_feature dev cam)
		$(meson_feature doc documentation)
		$(meson_feature udev udev)
		-Dandroid="enabled"
		-Dandroid_platform="cros"
		-Dpipelines="${LIBCAMERA_PIPELINES}"
		--buildtype "$(usex debug debug plain)"
		--sysconfdir /etc/camera
	)
	meson_src_configure
}

libcamera_src_compile() {
	meson_src_compile
}

libcamera_src_install() {
	meson_src_install

	dosym "../libcamera-hal.so" "/usr/$(get_libdir)/camera_hal/libcamera-hal.so"

	# TODO(b/291216477): Remove this when we don't need to sign IPA modules.
	dostrip -x "/usr/$(get_libdir)/libcamera/"
}

EXPORT_FUNCTIONS src_configure src_compile src_install

fi # _LIBCAMERA_ECLASS
