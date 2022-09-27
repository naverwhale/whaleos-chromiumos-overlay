# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE=(
	"github.com/maruel/subcommands de1d40e70d4b89b9c560a4d308e0bc9f5c9e18d7"
)

CROS_GO_PACKAGES=(
	"github.com/maruel/subcommands"
)

inherit cros-go

DESCRIPTION="Go subcommand library"
HOMEPAGE="https://github.com/maruel/subcommands"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/levenshtein"
RDEPEND="${DEPEND}"
