# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="e634681e8d5a0c7c26666fa150caee0f59003b1a"
CROS_WORKON_TREE=("2e394b5ab3993434c419afc6659ef37fec254cf8" "09223c9565cfeddc50300f068d28ed7083cff687")
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME=("../platform/dev")
CROS_WORKON_SUBTREE="src/chromiumos/test/publish src/chromiumos/test/util"

inherit cros-go cros-workon

DESCRIPTION="Publish server implementation for uploading test result artifacts to GCS bucket"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/dev-util/+/HEAD/src/chromiumos/test/publish"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

CROS_GO_WORKSPACE=(
	"${S}"
)

CROS_GO_BINARIES=(
	"chromiumos/test/publish/cmd/gcs-publish"
	"chromiumos/test/publish/cmd/tko-publish"
	"chromiumos/test/publish/cmd/rdb-publish"
	"chromiumos/test/publish/cmd/cpcon-publish"
)

CROS_GO_TEST=(
	"chromiumos/test/publish/cmd/..."
)

CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

DEPEND="
	dev-go/crypto
	dev-go/gcp-storage
	dev-go/grpc
	dev-go/infra-proto
	dev-go/luci-go
	dev-go/mock
	dev-go/protobuf
	dev-go/protobuf-legacy-api
	dev-util/lro-server
	chromeos-base/cros-config-api
"
RDEPEND="${DEPEND}"

src_prepare() {
	# CGO_ENABLED=0 will make the executable statically linked.
	export CGO_ENABLED=0

	default
}
