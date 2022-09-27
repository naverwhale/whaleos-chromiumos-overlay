# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="chromium.googlesource.com/infra/luci/luci-go:go.chromium.org/luci fbf085364d0e2db2aa35e78f526ca0d7468201a8"

CROS_GO_PACKAGES=(
	"go.chromium.org/luci/common/data/stringset"
	"go.chromium.org/luci/common/data/strpair"
	"go.chromium.org/luci/common/data/text/indented"
	"go.chromium.org/luci/common/errors"
	"go.chromium.org/luci/common/flag"
	"go.chromium.org/luci/common/iotools"
	"go.chromium.org/luci/common/logging"
	"go.chromium.org/luci/common/runtime/goroutine"
)

inherit cros-go

DESCRIPTION="LUCI-related packages and other common utility packages."
HOMEPAGE="https://chromium.googlesource.com/infra/luci/luci-go"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-go/gapi-googleapi
	dev-go/grpc
	dev-go/protobuf
"
RDEPEND="${DEPEND}"
