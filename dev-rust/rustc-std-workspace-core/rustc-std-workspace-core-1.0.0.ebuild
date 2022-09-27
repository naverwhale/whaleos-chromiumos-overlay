# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_EMPTY_CRATE=1

inherit cros-rust

CRIPTION="Empty ${PN} crate"
HOMEPAGE=""
LICENSE="BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"
