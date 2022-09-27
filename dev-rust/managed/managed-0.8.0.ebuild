# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="managed is a library that provides a way to logically own objects, whether or not heap allocation is available."
HOMEPAGE="https://github.com/smoltcp-rs/rust-managed"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="BSD"
SLOT="${PV}/${PR}"
KEYWORDS="*"
