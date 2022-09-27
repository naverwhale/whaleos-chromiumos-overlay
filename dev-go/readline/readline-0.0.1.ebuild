# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/chzyer/readline v1.4"

CROS_GO_PACKAGES=(
	"github.com/chzyer/readline"
)

CROS_GO_TEST=(
	"github.com/chzyer/readline"
)

inherit cros-go

DESCRIPTION="Readline is a pure go implementation for GNU-Readline kind library"
HOMEPAGE="https://https://github.com/chzyer/readline"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
