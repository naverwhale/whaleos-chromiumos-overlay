# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/google/gofountain 4928733085e9593b7dcdb0fe268b20e1e1184b6d"

CROS_GO_PACKAGES=(
	"github.com/google/gofountain"
)

inherit cros-go

DESCRIPTION="Go implementation of various fountain codes. Luby Transform, Online codes, Raptor code."
HOMEPAGE="https://github.com/google/gofountain"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
