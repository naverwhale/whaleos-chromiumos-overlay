# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the BSD license.

EAPI="7"

CROS_WORKON_COMMIT="c2e0a76ececf0566758e921a6e1791d201ee30f6"
CROS_WORKON_TREE="46004e0e5781880050cd53e1f573fda1e540cec5"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="chromeos-nvt-tcon-updater"

inherit cros-workon user

DESCRIPTION="Shell library for integrating the Novatek TCON Firmware updater"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-init
	chromeos-base/common-assets
	chromeos-base/minijail
	sys-apps/novatek-tcon-fw-update-tool
"

pkg_preinst() {
	enewgroup fwupdate-drm_dp_aux-i2c
	enewuser fwupdate-drm_dp_aux-i2c
}

src_install() {
	insinto "/opt/google/tcon/policies"
	doins chromeos-nvt-tcon-updater/policies/"${ARCH}"/nvt-tcon-fw-updater.update.policy

	insinto "/opt/google/tcon/scripts"
	doins chromeos-nvt-tcon-updater/scripts/chromeos-nvt-tcon-firmware-update.sh
}
