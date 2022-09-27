# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="ChromiumOS-specific configuration files for net-wireless/neard"
HOMEPAGE="http://www.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="
	net-wireless/neard
"

# Because this ebuild has no source package, "${S}" doesn't get
# automatically created.  The compile phase depends on "${S}" to
# exist, so we make sure "${S}" refers to a real directory.
#
# The problem is apparently an undocumented feature of EAPI 4;
# earlier versions of EAPI don't require this.
S="${WORKDIR}"

src_install() {
	# D-Bus configuration.
	insinto /etc/dbus-1/system.d
	newins "${FILESDIR}/${PN}"-dbus.conf org.neard.conf

	# Upstart configuration.
	insinto /etc/init
	newins "${FILESDIR}/${PN}"-upstart.conf neard.conf

	# udev rule.
	insinto /lib/udev/rules.d
	newins "${FILESDIR}/${PN}"-udev.rules 42-nfc.rules

	# neard configuration.
	insinto /etc/neard
	newins "${FILESDIR}/${PN}"-main.conf main.conf
}
