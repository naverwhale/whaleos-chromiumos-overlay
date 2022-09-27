# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_GO_SOURCE="github.com/google/fscrypt v${PV}"

CROS_GO_PACKAGES=(
	"github.com/google/fscrypt/metadata"
	"github.com/google/fscrypt/util"
)

inherit cros-go

DESCRIPTION="Go package for fscrypt utils "
HOMEPAGE="https://github.com/google/fscrypt"
SRC_URI="$(cros-go_src_uri)"


LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/crypto
	dev-go/go-sys
	sys-libs/pam:=
"
RDEPEND="${DEPEND}"
