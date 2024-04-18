# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/danjacques/gofslock 6e321f4509c8589652ac83307e867969aa1f6cde"

CROS_GO_PACKAGES=(
	"github.com/danjacques/gofslock/fslock"
)

inherit cros-go

DESCRIPTION="Go implementation of filesystem-level locking."
HOMEPAGE="https://github.com/danjacques/gofslock"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-go/go-sys"
RDEPEND="
	${DEPEND}
	!<=dev-go/luci-go-cipd-0.0.1-r1
"
