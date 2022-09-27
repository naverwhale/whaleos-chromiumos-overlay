# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_EMPTY_CRATE=1

inherit cros-rust

DESCRIPTION="Empty ${PN} crate"
HOMEPAGE=""

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"
