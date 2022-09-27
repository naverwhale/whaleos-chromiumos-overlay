# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_PROJECT="external/git.kernel.org/fs/xfs/xfstests-dev"
CROS_WORKON_MANUAL_UPREV="1"

inherit autotools cros-workon

DESCRIPTION="Filesystem tests suite"
HOMEPAGE="https://git.kernel.org/cgit/fs/xfs/xfstests-dev.git/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"

RDEPEND="sys-fs/e2fsprogs
	dev-lang/perl
	sys-apps/attr
	sys-apps/diffutils
	sys-apps/gawk
	sys-apps/util-linux
	sys-devel/bc
	sys-fs/xfsprogs
"

DEPEND="sys-apps/acl
	dev-libs/libaio
"

src_prepare() {
	eautoreconf
}

src_configure() {
	use kernel_linux && export PLATFORM=linux
	econf --prefix="${EPREFIX}/usr/local"
}
