# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="An XML library in pure Rust."
HOMEPAGE="http://netvl.github.io/xml-rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bitflags-0.5.0:= <dev-rust/bitflags-0.8.0
"
RDEPEND="${DEPEND}"

# Unexpected event at line 32:
# Expected: Characters("Cascading style sheet: © - ҉")
# Found:    Characters("Cascading style sheet: © - \u{489}")
RESTRICT="test"
