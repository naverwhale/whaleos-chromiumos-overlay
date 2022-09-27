# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/abema/go-mp4 9f0321600240dd93cb681da2d8d5adbfd87913a6"

CROS_GO_PACKAGES=(
	"github.com/abema/go-mp4/..."
)

inherit cros-go

DESCRIPTION="Go library for reading and writing MP4 file"
HOMEPAGE="https://github.com/abema/go-mp4"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
