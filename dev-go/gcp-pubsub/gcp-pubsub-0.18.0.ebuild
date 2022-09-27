# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# The dev-go/gcp* packages are all built from this repo.  They should
# be updated together.
CROS_GO_SOURCE="github.com/GoogleCloudPlatform/google-cloud-go:cloud.google.com/go v${PV}"

CROS_GO_PACKAGES=(
	"cloud.google.com/go/pubsub"
	"cloud.google.com/go/pubsub/apiv1"
	"cloud.google.com/go/pubsub/internal/distribution"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="Google Cloud Client Libraries for Go"
HOMEPAGE="https://code.googlesource.com/gocloud"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/gapi-bundler
	dev-go/gapi-iterator
	dev-go/gapi-option
	dev-go/gapi-transport
	dev-go/gax
	dev-go/gcp-iam
	dev-go/gcp-internal
	dev-go/genproto
	dev-go/grpc
	dev-go/net
	dev-go/opencensus
	dev-go/protobuf
	dev-go/sync
"
RDEPEND="${DEPEND}"
