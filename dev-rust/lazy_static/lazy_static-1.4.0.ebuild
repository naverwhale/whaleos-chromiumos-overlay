# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A macro for declaring lazily evaluated statics in Rust."
HOMEPAGE="https://github.com/rust-lang-nursery/lazy-static.rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

CROS_RUST_REMOVE_DEV_DEPS=1

DEPEND="
	=dev-rust/spin-0.5*:=
"
RDEPEND="${DEPEND}"

# error: could not compile `lazy_static`
RESTRICT="test"
