# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=6

CROS_GO_SOURCE="github.com/go-check/check:gopkg.in/check.v1 20d25e2804050c1cd24a7eea1e7a6447dd0e74ec"

CROS_GO_PACKAGES=(
	"gopkg.in/check.v1"
)

inherit cros-go

DESCRIPTION="Rich testing for the Go language"
HOMEPAGE="https://gopkg.in/check.v1"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
