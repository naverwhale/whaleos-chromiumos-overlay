# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/op/go-logging 970db520ece77730c7e4724c61121037378659d9"

CROS_GO_PACKAGES=(
	"github.com/op/go-logging"
)

inherit cros-go

DESCRIPTION="A logging infrastructure for Go"
HOMEPAGE="https://github.com/op/go-logging"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
