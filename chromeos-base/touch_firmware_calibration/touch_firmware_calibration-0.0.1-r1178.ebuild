# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "c7f5d93abf48655d8f69e8e2763be699e6c7c59e" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk touch_firmware_calibration .gn"

PLATFORM_SUBDIR="touch_firmware_calibration"

inherit cros-workon platform user udev

DESCRIPTION="Touch Firmware Calibration"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/touch_firmware_calibration/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

pkg_preinst() {
	# Set up touch_firmware_calibration user and group which will be used to
	# run tools for calibration.
	enewuser touch_firmware_calibration
	enewgroup touch_firmware_calibration
}

src_install() {
	platform_src_install

	# Install a tool to override max pressure.
	exeinto "$(get_udevdir)"
	doexe "${OUT}/override-max-pressure"

	# Install the correct seccomp policy for this architecture.
	insinto "/usr/share/policy"
	newins "seccomp/override-max-pressure-seccomp-${ARCH}.policy" override-max-pressure-seccomp.policy
}
