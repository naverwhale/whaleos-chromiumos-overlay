# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Procedural macros in expression position"
HOMEPAGE="https://github.com/dtolnay/proc-macro-hack"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

RDEPEND="!~dev-rust/${PN}-0.5.11"

# error: could not compile `proc-macro-hack`
RESTRICT="test"
