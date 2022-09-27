# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5
CROS_GO_SOURCE=(
	"github.com/moby/moby:github.com/docker/docker 5f0703c549935d2cfec42b468b858d822b58a27e"
	"github.com/containerd/containerd v1.5.1"
	"github.com/docker/distribution v2.7.1"
	"github.com/docker/go-connections 88e5af338bb1e6c7f51b69cc1864249d1e8f4786"
	"github.com/docker/go-units 519db1ee28dcc9fd2474ae59fca29a810482bfb1"
	"github.com/gogo/protobuf 226206f39bd7276e88ec684ea0028c18ec2c91ae"
	"github.com/opencontainers/go-digest v1.0.0"
	"github.com/opencontainers/image-spec v1.0.1"
	"github.com/sirupsen/logrus v1.8.1"
)

CROS_GO_PACKAGES=(
	"github.com/containerd/containerd/errdefs"
	"github.com/docker/distribution/digestset"
	"github.com/docker/distribution/reference"
	"github.com/docker/distribution/registry/api/errcode"
	"github.com/docker/docker/api"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/blkiodev"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/events"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/api/types/image"
	"github.com/docker/docker/api/types/mount"
	"github.com/docker/docker/api/types/network"
	"github.com/docker/docker/api/types/registry"
	"github.com/docker/docker/api/types/strslice"
	"github.com/docker/docker/api/types/swarm"
	"github.com/docker/docker/api/types/swarm/runtime"
	"github.com/docker/docker/api/types/time"
	"github.com/docker/docker/api/types/versions"
	"github.com/docker/docker/api/types/volume"
	"github.com/docker/docker/client"
	"github.com/docker/docker/errdefs"
	"github.com/docker/go-connections/nat"
	"github.com/docker/go-connections/sockets"
	"github.com/docker/go-connections/tlsconfig"
	"github.com/docker/go-units"
	"github.com/gogo/protobuf/proto"
	"github.com/opencontainers/go-digest"
	"github.com/opencontainers/image-spec/specs-go"
	"github.com/opencontainers/image-spec/specs-go/v1"
	"github.com/sirupsen/logrus"
)

inherit cros-go

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

DESCRIPTION="Docker SDK in Go"
HOMEPAGE="mobyproject.org"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/protobuf
	dev-go/crypto
	dev-go/grpc
	dev-go/text
	dev-go/net
	dev-go/go-sys
	dev-go/errors
"
RDEPEND="${DEPEND}"
