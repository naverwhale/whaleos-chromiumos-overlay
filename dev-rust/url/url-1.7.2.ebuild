# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="URL library for Rust, based on the URL Standard"
HOMEPAGE="https://github.com/servo/rust-url"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/idna-0.1*:=
	=dev-rust/matches-0.1*:=
	=dev-rust/percent-encoding-1*:=
	=dev-rust/encoding-0.2*:=
	=dev-rust/heapsize-0.4*:=
	=dev-rust/rustc-serialize-0.3*:=
	=dev-rust/serde-0.8*:=
	=dev-rust/bencher-0.1*:=
	=dev-rust/rustc-test-0.3*:=
	=dev-rust/serde_json-0.8*:=
"

# error: could not compile `url`
RESTRICT="test"
