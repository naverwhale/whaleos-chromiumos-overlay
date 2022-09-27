# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Install packages that must live in the rootfs in dev images."
HOMEPAGE="http://www.chromium.org/"
KEYWORDS="*"
LICENSE="BSD-Google"
SLOT="0"
IUSE=""

RDEPEND="
	chromeos-base/openssh-server-init
	chromeos-base/virtual-usb-printer
	virtual/chromeos-bsp-dev-root
"
