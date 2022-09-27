# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/mitchellh/go-homedir b8bc1bf767474819792c23f32d8286a45736f1c6"

CROS_GO_PACKAGES=(
	"github.com/mitchellh/go-homedir"
)

inherit cros-go

DESCRIPTION="Go library for detecting the user's home directory"
HOMEPAGE="https://github.com/mitchellh/go-homedir"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
# Unittests cannot be run from emerge as it overrides ${HOME}.
RESTRICT="binchecks test strip"

DEPEND=""
RDEPEND="${DEPEND}"
