# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/mafredri/cdp v0.31.0"

CROS_GO_PACKAGES=(
	"github.com/mafredri/cdp"
	"github.com/mafredri/cdp/devtool"
	"github.com/mafredri/cdp/internal/..."
	"github.com/mafredri/cdp/protocol/..."
	"github.com/mafredri/cdp/rpcc"
	"github.com/mafredri/cdp/session"
)

CROS_GO_TEST=(
	# Exclude the main cdp package, as Example_incognito is failing with
	# "... dial tcp [::1]:9222: connect: connection refused"
	"github.com/mafredri/cdp/devtool"
	"github.com/mafredri/cdp/internal/..."
	"github.com/mafredri/cdp/protocol/..."
	"github.com/mafredri/cdp/rpcc"
	"github.com/mafredri/cdp/session"
)

inherit cros-go

DESCRIPTION="Type-safe bindings for the Chrome Debugging Protocol written in Go"
HOMEPAGE="https://github.com/mafredri/cdp"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"

DEPEND="
	test? (
		dev-go/cmp
		dev-go/sync
	)"
RDEPEND="dev-go/websocket"
