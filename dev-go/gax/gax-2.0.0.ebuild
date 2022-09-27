# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/googleapis/gax-go v${PV}"

CROS_GO_PACKAGES=(
	"github.com/googleapis/gax-go"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="Google API Extensions for Go"
HOMEPAGE="https://github.com/googleapis/gax-go"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/grpc"
RDEPEND="${DEPEND}"
