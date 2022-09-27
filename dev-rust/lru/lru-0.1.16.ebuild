# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="An implementation of a LRU cache. The cache supports put, get, get_mut and pop operations, all of which are O(1). This crate was heavily influenced by the LRU Cache implementation in an earlier version of Rust's std::collections crate."
HOMEPAGE="https://github.com/jeromefroe/lru-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/hashbrown-0.1*:=
	=dev-rust/scoped_threadpool-0.1*:=
"
