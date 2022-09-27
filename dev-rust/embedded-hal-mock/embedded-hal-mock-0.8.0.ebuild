# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='A Hardware Abstraction Layer (HAL) mock for embedded systems'
HOMEPAGE='https://crates.io/crates/embedded-hal-mock'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/nb-0.1.3:= <dev-rust/nb-0.2.0
	>=dev-rust/embedded-hal-0.2.5:= <dev-rust/embedded-hal-0.3.0
"
RDEPEND="${DEPEND}"

# This file was crafted by hand.
