# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/golang/glog 44145f04b68cf362d9c4df2182967c2275eaefed"

CROS_GO_PACKAGES=(
	"github.com/golang/glog"
)

inherit cros-go

DESCRIPTION="Leveled execution logs for Go"
HOMEPAGE="https://github.com/golang/glog"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
