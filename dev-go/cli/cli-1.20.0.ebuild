# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=6

CROS_GO_SOURCE="github.com/urfave/cli v${PV}"

CROS_GO_PACKAGES=(
	"github.com/urfave/cli"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="A simple, fast, and fun package for building command line apps in Go"
HOMEPAGE="https://github.com/urfave/cli"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""
