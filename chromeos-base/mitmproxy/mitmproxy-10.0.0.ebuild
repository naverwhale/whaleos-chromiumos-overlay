# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

SRC_URI="gs://chromeos-localmirror/distfiles/${P}-linux.tar.gz"

DESCRIPTION="This command-line tool lets clients execute mimtproxy"
HOMEPAGE="https://github.com/mitmproxy/mitmproxy"
RESTRICT="binchecks strip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	sys-libs/zlib:=
"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	dobin mitmdump
}
