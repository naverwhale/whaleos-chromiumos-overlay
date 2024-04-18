# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="a7fda17019fb0c5ed3ddbd787af288c440ddc21b"
CROS_WORKON_TREE="2a1d9b4fd4ef1223fc2a0dafcc898b5fb3955823"
CROS_WORKON_PROJECT="chromiumos/platform/touchpad-tests"
CROS_WORKON_LOCALNAME="../platform/touchpad-tests"

inherit cros-workon cros-constants

DESCRIPTION="Chromium OS multitouch driver regression tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/touchpad-tests"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/gestures
	chromeos-base/libevdev:=
	app-misc/utouch-evemu
	x11-base/xorg-proto"
DEPEND=${RDEPEND}

src_install() {
	# install to autotest deps directory for dependency
	emake DESTDIR="${D}${AUTOTEST_BASE}/client/deps/touchpad-tests" install
}
