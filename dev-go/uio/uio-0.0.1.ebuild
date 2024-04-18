# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_GO_SOURCE="github.com/u-root/uio dac05f7d2cb496e9b7fc45559338b1f8dd55b554"

CROS_GO_PACKAGES=(
	"github.com/u-root/uio/ulog"
	"github.com/u-root/uio/cp"
)

inherit cros-go

DESCRIPTION="Utilities and helpers for dev-go/u-root."
HOMEPAGE="https://github.com/u-root/uio"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
