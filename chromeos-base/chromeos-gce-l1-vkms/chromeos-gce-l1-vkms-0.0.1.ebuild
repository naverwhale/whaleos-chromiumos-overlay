# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Install vkms kernel module for running CrOS/ARCVM on GCE as L1 guest."
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	insinto /etc/init
	doins "${FILESDIR}"/vkms.conf
}
