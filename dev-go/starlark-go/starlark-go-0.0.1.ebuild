# Copyright 2021 Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE=(
	"github.com/google/starlark-go:go.starlark.net 87f333178d5942de51b193111d6f636c79833ea5"
	"github.com/chzyer/logex v1.1.10"
	"github.com/chzyer/readline 2972be24d48e78746da79ba8e24e8b488c9880de"
	"github.com/chzyer/test a1ea475d72b168a29f44221e0ad031a842642302"
)

CROS_GO_BINARIES=(
	"go.starlark.net/cmd/starlark/"
)

inherit cros-go

DESCRIPTION="Go impl of the starlark config language"
HOMEPAGE="https://github.com/google/starlark-go"
SRC_URI="$(cros-go_src_uri)"
RESTRICT="binchecks strip"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="
	dev-go/cmp
	dev-go/go-sys
	dev-go/protobuf
	dev-go/xerrors
"

RDEPEND=""

src_install() {
	dobin starlark
}
