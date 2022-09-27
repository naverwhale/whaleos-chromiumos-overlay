# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="go.googlesource.com/sync:golang.org/x/sync f52d1811a62927559de87708c8913c1650ce4f26"

CROS_GO_PACKAGES=(
	"golang.org/x/sync/errgroup"
	"golang.org/x/sync/semaphore"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="Additional Go concurrency primitives"
HOMEPAGE="https://golang.org/x/sync"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND="dev-go/net"
