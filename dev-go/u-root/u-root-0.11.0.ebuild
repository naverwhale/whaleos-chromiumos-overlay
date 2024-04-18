# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_GO_SOURCE="github.com/u-root/u-root 4dad982f78a72202985296afdfbc47c274ccc944"

inherit cros-go

DESCRIPTION="A fully Go userland with Linux bootloaders"
HOMEPAGE="https://github.com/u-root/u-root"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

CROS_GO_BINARIES=(
	"github.com/u-root/u-root"
)

DEPEND="
	dev-go/gobusybox
	dev-go/go-tools
	dev-go/go-humanize
	dev-go/goterm
	dev-go/lz4
	dev-go/uio
"
RDEPEND="${DEPEND}"

src_install() {
	cros-go_src_install
	insinto /usr/share/u-root/
	doins -r src
}
