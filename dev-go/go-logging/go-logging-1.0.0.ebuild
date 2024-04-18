# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/op/go-logging v1"

CROS_GO_PACKAGES=(
	"github.com/op/go-logging"
)

inherit cros-go

DESCRIPTION="Golang logging library"
HOMEPAGE="https://github.com/op/go-logging"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
RDEPEND="!<=dev-go/luci-go-common-0.0.1-r12"
