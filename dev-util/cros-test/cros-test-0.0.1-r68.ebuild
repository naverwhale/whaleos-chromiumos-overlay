# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="60f2adfab379a427e9a78aaac477ad00b35d9e5d"
CROS_WORKON_TREE=("2deb39fe4acba30f3654d80440e0415df3798933" "09223c9565cfeddc50300f068d28ed7083cff687")
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME=("../platform/dev")
CROS_WORKON_SUBTREE="src/chromiumos/test/execution src/chromiumos/test/util"

inherit cros-go cros-workon

DESCRIPTION="Test execution server for running tests and capturing results"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/dev-util/+/HEAD/src/chromiumos/test/execution"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

CROS_GO_VERSION="${PF}"

CROS_GO_BINARIES=(
	"chromiumos/test/execution/cmd/cros-test"
)

CROS_GO_PACKAGES=(
	"chromiumos/test/execution/errors/..."
	"chromiumos/test/util/..."
)

CROS_GO_TEST=(
	"chromiumos/test/execution/cmd/cros-test/..."
)

CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

DEPEND="
	chromeos-base/tast-cmd:=
	chromeos-base/tast-proto
	dev-go/cmp
	dev-go/grpc
	dev-go/luci-go
	dev-go/protobuf-legacy-api
	dev-util/lro-server
"
RDEPEND="${DEPEND}"

src_prepare() {
	# Disable cgo and PIE on building Tast binaries. See:
	# https://crbug.com/976196
	# https://github.com/golang/go/issues/30986#issuecomment-475626018
	export CGO_ENABLED=0
	export GOPIE=0

	default
}
