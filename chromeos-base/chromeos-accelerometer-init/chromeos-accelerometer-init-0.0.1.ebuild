# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit udev

DESCRIPTION="Chrome OS trigger allowing chrome to access cros-ec-accel device"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!chromeos-base/iioservice
	chromeos-base/mems_setup
	virtual/chromeos-ec-driver-init
	virtual/modutils
	virtual/udev
"

S=${WORKDIR}

src_test() {
	local cmds=(
		"${FILESDIR}"/tests/accelerometer-init-test.sh
		"${FILESDIR}"/tests/light-init-test.sh
	)
	local cmd

	for cmd in "${cmds[@]}"; do
		echo "${cmd[@]}"
		"${cmd[@]}" || die
	done
}

src_install() {
	insinto /etc/init
	doins "${FILESDIR}"/init/cros-ec-accel.conf
}
