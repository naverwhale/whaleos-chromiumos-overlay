# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# pick go-tools at the current head of release-branch.go1.15
# c1934b75d054975b79a8179cb6f0a9b8b3fa33cd (HEAD -> release-branch.go1.15)
CROS_GO_SOURCE="go.googlesource.com/tools:golang.org/x/tools c1934b75d054975b79a8179cb6f0a9b8b3fa33cd"

CROS_GO_PACKAGES=(
	"golang.org/x/tools/go/ast/astutil"
	"golang.org/x/tools/go/buildutil"
	"golang.org/x/tools/go/gcexportdata"
	"golang.org/x/tools/go/internal/cgo"
	"golang.org/x/tools/go/internal/gcimporter"
	"golang.org/x/tools/go/internal/packagesdriver"
	"golang.org/x/tools/go/loader"
	"golang.org/x/tools/go/packages"
	"golang.org/x/tools/internal/event"
	"golang.org/x/tools/internal/event/core"
	"golang.org/x/tools/internal/event/keys"
	"golang.org/x/tools/internal/event/label"
	"golang.org/x/tools/internal/fastwalk"
	"golang.org/x/tools/internal/gocommand"
	"golang.org/x/tools/internal/gopathwalk"
	"golang.org/x/tools/internal/packagesinternal"
	"golang.org/x/tools/internal/typesinternal"
	"golang.org/x/tools/imports"
	"golang.org/x/tools/internal/imports"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

CROS_GO_BINARIES=(
	"golang.org/x/tools/cmd/godoc"
	"golang.org/x/tools/cmd/goimports"
	"golang.org/x/tools/cmd/guru:goguru"
	"golang.org/x/tools/cmd/stringer"
)

inherit cros-go

DESCRIPTION="Packages and tools that support the Go programming language"
HOMEPAGE="https://golang.org/x/tools"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/mod
	dev-go/net
	dev-go/xerrors
"
RDEPEND="${DEPEND}"
