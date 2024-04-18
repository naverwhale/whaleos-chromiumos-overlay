# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE=(
	"chromium.googlesource.com/infra/luci/luci-go:go.chromium.org/luci cf043d12a8d3221e5dd7705a69b066c064f9f829"
)

CROS_GO_PACKAGES=(
	"go.chromium.org/luci/auth"
	"go.chromium.org/luci/auth/identity"
	"go.chromium.org/luci/auth/integration/localauth/rpcs"
	"go.chromium.org/luci/auth/internal"
	"go.chromium.org/luci/auth/loginsessionspb"
	"go.chromium.org/luci/buildbucket"
	"go.chromium.org/luci/buildbucket/proto"
	"go.chromium.org/luci/cipd/api/cipd/v1"
	"go.chromium.org/luci/cipd/client/cipd"
	"go.chromium.org/luci/cipd/client/cipd/configpb"
	"go.chromium.org/luci/cipd/client/cipd/deployer"
	"go.chromium.org/luci/cipd/client/cipd/digests"
	"go.chromium.org/luci/cipd/client/cipd/ensure"
	"go.chromium.org/luci/cipd/client/cipd/fs"
	"go.chromium.org/luci/cipd/client/cipd/internal"
	"go.chromium.org/luci/cipd/client/cipd/internal/messages"
	"go.chromium.org/luci/cipd/client/cipd/internal/retry"
	"go.chromium.org/luci/cipd/client/cipd/pkg"
	"go.chromium.org/luci/cipd/client/cipd/platform"
	"go.chromium.org/luci/cipd/client/cipd/plugin"
	"go.chromium.org/luci/cipd/client/cipd/plugin/host"
	"go.chromium.org/luci/cipd/client/cipd/plugin/plugins"
	"go.chromium.org/luci/cipd/client/cipd/plugin/plugins/admission"
	"go.chromium.org/luci/cipd/client/cipd/plugin/protocol"
	"go.chromium.org/luci/cipd/client/cipd/reader"
	"go.chromium.org/luci/cipd/client/cipd/template"
	"go.chromium.org/luci/cipd/client/cipd/ui"
	"go.chromium.org/luci/cipd/common"
	"go.chromium.org/luci/cipd/common/cipderr"
	"go.chromium.org/luci/cipd/version"
	"go.chromium.org/luci/common/bq/pb"
	"go.chromium.org/luci/common/clock"
	"go.chromium.org/luci/common/data/cmpbin"
	"go.chromium.org/luci/common/data/rand/mathrand"
	"go.chromium.org/luci/common/data/sortby"
	"go.chromium.org/luci/common/data/stringset"
	"go.chromium.org/luci/common/data/strpair"
	"go.chromium.org/luci/common/data/text"
	"go.chromium.org/luci/common/data/text/indented"
	"go.chromium.org/luci/common/errors"
	"go.chromium.org/luci/common/flag"
	"go.chromium.org/luci/common/gcloud/googleoauth"
	"go.chromium.org/luci/common/gcloud/iam"
	"go.chromium.org/luci/common/iotools"
	"go.chromium.org/luci/common/logging"
	"go.chromium.org/luci/common/logging/gologger"
	"go.chromium.org/luci/common/logging/memlogger"
	"go.chromium.org/luci/common/proto"
	"go.chromium.org/luci/common/proto/structmask"
	"go.chromium.org/luci/common/proto/textpb"
	"go.chromium.org/luci/common/retry"
	"go.chromium.org/luci/common/retry/transient"
	"go.chromium.org/luci/common/runtime/goroutine"
	"go.chromium.org/luci/common/runtime/paniccatcher"
	"go.chromium.org/luci/common/sync/parallel"
	"go.chromium.org/luci/common/sync/promise"
	"go.chromium.org/luci/common/system/environ"
	"go.chromium.org/luci/common/system/signals"
	"go.chromium.org/luci/common/system/terminal"
	"go.chromium.org/luci/gae/internal/zstd"
	"go.chromium.org/luci/gae/service/blobstore"
	"go.chromium.org/luci/gae/service/datastore"
	"go.chromium.org/luci/gae/service/datastore/internal/protos/datastore"
	"go.chromium.org/luci/gae/service/datastore/internal/protos/multicursor"
	"go.chromium.org/luci/gae/service/info"
	"go.chromium.org/luci/grpc/discovery"
	"go.chromium.org/luci/grpc/grpcutil"
	"go.chromium.org/luci/grpc/prpc"
	"go.chromium.org/luci/hardcoded/chromeinfra"
	"go.chromium.org/luci/lucictx"
	"go.chromium.org/luci/resultdb/proto/v1"
	"go.chromium.org/luci/server/auth/delegation/messages"
	"go.chromium.org/luci/server/router"
	"go.chromium.org/luci/starlark/interpreter"
	"go.chromium.org/luci/starlark/starlarkproto"
	"go.chromium.org/luci/starlark/typed"
	"go.chromium.org/luci/swarming/proto/api"
	"go.chromium.org/luci/tokenserver/api"
	"go.chromium.org/luci/tokenserver/api/minter/v1"
)

inherit cros-go

DESCRIPTION="LUCI-related packages"
HOMEPAGE="https://chromium.googlesource.com/infra/luci/luci-go"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-go/appengine
	dev-go/gapi
	dev-go/go-homedir
	dev-go/go-logging
	dev-go/gofslock
	dev-go/grpc
	dev-go/httprouter
	dev-go/klauspost-compress
	dev-go/protobuf
	dev-go/protobuf-legacy-api
	dev-go/starlark-go
	dev-go/txtpbfmt
	dev-go/yaml:0
"
RDEPEND="
	${DEPEND}
	!dev-go/luci-go-common
	!dev-go/luci-go-cipd
"
