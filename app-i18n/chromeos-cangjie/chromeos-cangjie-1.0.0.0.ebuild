# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="The Chinese Cangjie input engine for IME extension API"
HOMEPAGE="https://github.com/google/google-input-tools"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${PN}"

PATCHES=(
	"${FILESDIR}"/${P}-insert-public-key.patch
	"${FILESDIR}"/${P}-fix-permission.patch
)

src_install() {
	insinto /usr/share/chromeos-assets/input_methods/cangjie
	doins -r ./*
}
