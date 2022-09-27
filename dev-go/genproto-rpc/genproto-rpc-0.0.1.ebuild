# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# The dev-go/genproto* packages are all built from this repo.  They should
# be updated together.
CROS_GO_SOURCE="github.com/google/go-genproto:google.golang.org/genproto 2b5a72b8730b0b16380010cfe5286c42108d88e7"

CROS_GO_PACKAGES=(
	"google.golang.org/genproto/googleapis/rpc/code"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/genproto/googleapis/rpc/status"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="Go generated proto packages"
HOMEPAGE="https://github.com/googleapis/googleapis/"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/protobuf"
RDEPEND="
	${DEPEND}
	!<dev-go/genproto-0.0.1-r5
"
