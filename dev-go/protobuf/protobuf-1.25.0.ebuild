# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE=(
	"github.com/golang/protobuf v1.3.2"
	"github.com/protocolbuffers/protobuf-go:google.golang.org/protobuf v${PV}"
)

CROS_GO_PACKAGES=(
	"github.com/golang/protobuf/descriptor"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/protoc-gen-go/descriptor"
	"github.com/golang/protobuf/ptypes/..."
	"google.golang.org/protobuf/encoding/..."
	"google.golang.org/protobuf/internal/descfmt"
	"google.golang.org/protobuf/internal/descopts"
	"google.golang.org/protobuf/internal/detrand"
	"google.golang.org/protobuf/internal/encoding/..."
	"google.golang.org/protobuf/internal/errors"
	"google.golang.org/protobuf/internal/fieldsort"
	"google.golang.org/protobuf/internal/filedesc"
	"google.golang.org/protobuf/internal/filetype"
	"google.golang.org/protobuf/internal/flags"
	"google.golang.org/protobuf/internal/genid"
	"google.golang.org/protobuf/internal/impl"
	"google.golang.org/protobuf/internal/mapsort"
	"google.golang.org/protobuf/internal/msgfmt"
	"google.golang.org/protobuf/internal/pragma"
	"google.golang.org/protobuf/internal/set"
	"google.golang.org/protobuf/internal/strs"
	"google.golang.org/protobuf/internal/version"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/..."
	"google.golang.org/protobuf/runtime/..."
	"google.golang.org/protobuf/testing/..."
	"google.golang.org/protobuf/types/..."
)

CROS_GO_BINARIES=(
	"github.com/golang/protobuf/protoc-gen-go"
)

inherit cros-go

DESCRIPTION="Go support for Google's protocol buffers"
HOMEPAGE="https://github.com/protocolbuffers/protobuf-go"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"

DEPEND="dev-go/cmp
	test? ( dev-go/sync )"
RDEPEND=""
