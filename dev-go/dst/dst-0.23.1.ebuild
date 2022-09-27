# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/dave/dst v${PV}"

CROS_GO_PACKAGES=(
	"github.com/dave/dst/..."
)

inherit cros-go

DESCRIPTION="Decorated Syntax Tree"
HOMEPAGE="https://github.com/dave/dst"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/jennifer
	>=dev-go/go-tools-0.0.1-r13
"
RDEPEND="${DEPEND}"
