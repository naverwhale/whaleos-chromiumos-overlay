# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="2927fce20adf74b0c9a32a61e3edff894221f283"
CROS_WORKON_TREE="557307a70c32f48207a6ce6542d5a0035a0e098c"
CROS_WORKON_PROJECT="chromiumos/platform/experimental"
CROS_WORKON_LOCALNAME="../platform/experimental"

inherit cros-workon

DESCRIPTION="A memory consumer to allocate mlocked (non-swappable) memory"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/experimental/+/master/memory-eater-locked/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

RDEPEND=""
DEPEND=""

src_compile() {
	tc-export CC
	emake memory-eater-locked/memory-eater-locked || die "end compile failed."
}

src_install() {
	dobin memory-eater-locked/memory-eater-locked
}
