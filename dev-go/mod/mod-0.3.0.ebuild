# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

# pick mod at the current head of release-branch.go1.15
# commit 859b3ef565e237f9f1a0fb6b55385c497545680d (HEAD -> release-branch.go1.15, tag: v0.3.0, origin/release-branch.go1.15)
CROS_GO_SOURCE="go.googlesource.com/mod:golang.org/x/mod v${PV}"

CROS_GO_PACKAGES=(
	"golang.org/x/mod/module"
	"golang.org/x/mod/modfile"
	"golang.org/x/mod/semver"
	"golang.org/x/mod/internal/lazyregexp"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="packages for writing tools that work directly with Go module mechanics"
HOMEPAGE="https://golang.org/x/mod"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/xerrors
"
RDEPEND="${DEPEND}"
