# Copyright (c) 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the BSD license.

EAPI=7
CROS_WORKON_COMMIT="97e19f6c183413affb7dbef8b4265234b78f6365"
CROS_WORKON_TREE="85c862c58d2ad4b07479b1b9ac509b5c1e65c538"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_LOCALNAME="touch_updater"
CROS_WORKON_SUBTREE="stupdate"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon user

DESCRIPTION="Wrapper for ST touch firmware updater."
HOMEPAGE="https://www.chromium.org/chromium-os"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-touch-common
	sys-apps/st-touch-fw-updater
	!<chromeos-base/touch_updater-0.0.1-r167
"

pkg_preinst() {
	enewgroup fwupdate-i2c
	enewuser fwupdate-i2c
}

src_install() {
	exeinto "/opt/google/touch/scripts"
	doexe stupdate/scripts/*.sh

	if [ -d "stupdate/policies/${ARCH}" ]; then
		insinto "/opt/google/touch/policies"
		doins stupdate/policies/"${ARCH}"/*.policy
	fi
}
