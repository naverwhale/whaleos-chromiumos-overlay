# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A HashMap wrapper that holds key-value pairs in insertion order"
HOMEPAGE="https://github.com/contain-rs/linked-hash-map"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/clippy-0.0*:=
	=dev-rust/heapsize-0.4*:=
	=dev-rust/serde-1*:=
	=dev-rust/serde_test-1*:=
"

# thread 'test_consuming_iter_empty' panicked at 'attempted to leave type `std::collections::HashMap<linked_hash_map::KeyRef<&str>, *mut linked_hash_map::Node<&str, i32>>` uninitialized, which is invalid', /var/tmp/portage/dev-lang/rust-1.51.0/work/rustc-1.51.0-src/library/core/src/mem/mod.rs:671:9
RESTRICT="test"
