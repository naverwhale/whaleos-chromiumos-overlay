# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/google/go-tspi v${PV}"

CROS_GO_PACKAGES=(
	"github.com/google/go-tspi/tspiconst"
	"github.com/google/go-tspi/verification"
)

inherit cros-go

DESCRIPTION="TSPI bindings for golang"
HOMEPAGE="https://github.com/google/go-tspi"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/certificate-transparency-go"
RDEPEND=""
