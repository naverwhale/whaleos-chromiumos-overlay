# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ade4bed969f27b7143ca671f95cb07738e9d49ef"
CROS_WORKON_TREE="4b946e9c995155a84021703c48444873d8061a9e"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME=("../platform/dev")
CROS_WORKON_SUBTREE="src/chromiumos/test/lab/local"

inherit cros-go cros-workon

DESCRIPTION="Local test lab environment support (local DUT setup/wiring support for test execution)"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/dev-util/+/HEAD/src/chromiumos/test/lab/local"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

CROS_GO_WORKSPACE=(
	"${S}"
)

CROS_GO_BINARIES=(
	"chromiumos/test/lab/local/cmd/inventoryserver"
)

CROS_GO_TEST=(
	"chromiumos/test/lab/local/cmd/inventoryserver/..."
)

CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

DEPEND="
	dev-go/genproto-rpc
	dev-go/mock
	dev-go/protobuf
	chromeos-base/cros-config-api
"
RDEPEND="${DEPEND}"
