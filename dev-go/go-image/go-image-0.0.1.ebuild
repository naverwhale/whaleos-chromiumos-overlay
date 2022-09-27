# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="go.googlesource.com/image:golang.org/x/image 9130b4cfad522142c86367afe5e34ce811a85a4b"

CROS_GO_PACKAGES=(
	"golang.org/x/image/..."
	"golang.org/x/image/font/opentype"
)

CROS_GO_TEST=(
	"golang.org/x/image"
)

inherit cros-go

DESCRIPTION="Go packages for image libraries"
HOMEPAGE="https://go.googlesource.com/image"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/text"
RDEPEND=""
