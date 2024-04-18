# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_GO_SOURCE="github.com/u-root/gobusybox 46b2883a7f908fe80f7a9580e136b8d256856c47"

PATCHES=(
	"${FILESDIR}"/0001-findpkg-replace-go-multierror-dep-with-std-errors.patch
)

CROS_GO_PACKAGES=(
	"github.com/u-root/gobusybox/src/pkg/..."
)

inherit cros-go

DESCRIPTION="Tools for compiling many Go commands into one binary to save space."
HOMEPAGE="https://github.com/u-root/gobusybox"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND="
	dev-go/mod
"
