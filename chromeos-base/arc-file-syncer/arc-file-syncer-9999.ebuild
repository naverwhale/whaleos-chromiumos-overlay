# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/container/file-syncer .gn"

PLATFORM_SUBDIR="arc/container/file-syncer"

inherit cros-workon platform

DESCRIPTION="D-Bus service to mount OBB files"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/arc/container/file-syncer"

LICENSE="BSD-Google"
KEYWORDS="~*"

RDEPEND="
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
"
