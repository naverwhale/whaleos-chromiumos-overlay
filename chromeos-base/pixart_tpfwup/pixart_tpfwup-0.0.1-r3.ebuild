# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
DESCRIPTION="Pixart Touchpad utility tool for Firmware Update"
PROJ_NAME=pix_tpfwup
HOMEPAGE="https://github.com/pixarteswd/pix_tpfwup"
SRC_URI="https://github.com/pixarteswd/${PROJ_NAME}/archive/v${PVR}.tar.gz -> ${PF}.tar.gz"
S="${WORKDIR}/${PROJ_NAME}-${PVR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	dosbin pixtpfwup
}
