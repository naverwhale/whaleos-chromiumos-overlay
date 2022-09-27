# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/gonum/plot:gonum.org/v1/plot 4abb28f724d5129237103b5844685e7d60f93cfd"

CROS_GO_PACKAGES=(
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/palette"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/tools/..."
	"gonum.org/v1/plot/vg/..."
)

CROS_GO_TEST=(
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/cmpimg"
)

inherit cros-go

DESCRIPTION="Provides an API for setting up plots, and primitives for drawing on plots"
HOMEPAGE="https://www.gonum.org/"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/fogleman-gg
	dev-go/rsc-io-pdf
	dev-go/svgo
"

RDEPEND=""
