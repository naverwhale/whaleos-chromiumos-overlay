# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT="chromiumos/platform/experimental"
CROS_WORKON_LOCALNAME="../platform/experimental"

inherit cros-workon

DESCRIPTION="A memory consumer to allocate mlocked (non-swappable) memory"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/experimental/+/master/memory-eater-locked/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"
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
