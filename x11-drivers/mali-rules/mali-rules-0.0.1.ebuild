# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit udev

DESCRIPTION="Rules for setting permissions right on /dev/mali0"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

# Because this ebuild has no source package, "${S}" doesn't get
# automatically created.  The compile phase depends on "${S}" to
# exist, so we make sure "${S}" refers to a real directory.
#
# The problem is apparently an undocumented feature of EAPI 4;
# earlier versions of EAPI don't require this.
S="${WORKDIR}"

src_install() {
	udev_dorules "${FILESDIR}"/50-mali.rules
}
