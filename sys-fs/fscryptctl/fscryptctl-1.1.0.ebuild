# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-sanitizers toolchain-funcs

DESCRIPTION="fscrypt key management tool"
HOMEPAGE="https://github.com/google/fscryptctl"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="sys-fs/e2fsprogs:="

DEPEND="${RDEPEND}"

DOCS=( NEWS.md README.md fscryptctl.1.md )

PATCHES=(
	"${FILESDIR}/ignore-pandoc.patch" # b/300170623#comment4
)

src_configure() {
	sanitizers-setup-env
	append-lfs-flags
	tc-export CC
}
