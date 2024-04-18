# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit udev

DESCRIPTION="Install visl kernel module for running CrOS stateless V4L2
decoder tests."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	insinto /etc/init
	doins "${FILESDIR}"/visl.conf
	# udev rules for visl codec
	udev_dorules "${FILESDIR}/50-visl.rules"
}
