# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="7"
CROS_WORKON_PROJECT="chromiumos/third_party/em100"

inherit cros-workon toolchain-funcs

DESCRIPTION="A simple utility to control a Dediprog EM100pro from Linux"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

DEPEND="virtual/libusb:1"
RDEPEND="${DEPEND}"

src_configure() {
	tc-export CC PKG_CONFIG
}

src_install() {
	dosbin em100
}
