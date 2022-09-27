# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit systemd

DESCRIPTION="Install the upstart job that creates the swap and zram."
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="diskswap systemd"

RDEPEND="
	sys-apps/util-linux
	diskswap? ( sys-fs/cryptsetup )
	"

S=${WORKDIR}

src_install() {
	if use systemd; then
		systemd_dounit "${FILESDIR}"/init/swap.service
		systemd_enable_service system-services.target swap.service
	else
		insinto /etc/init
		doins "${FILESDIR}"/init/*.conf
	fi
	exeinto /usr/share/cros/init
	doexe "${FILESDIR}"/init/swap.sh
	if use diskswap; then
		sed -i '/local disk_based_swap_enabled=/s/false/true/' \
			"${D}/usr/share/cros/init/swap.sh" || die
	fi
}
