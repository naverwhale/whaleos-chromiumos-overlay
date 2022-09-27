# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Serialization and deserialization support provided by the compiler in the form of derive(RustcEncodable, RustcDecodable)."
HOMEPAGE="https://github.com/rust-lang-deprecated/rustc-serialize"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/rand-0.3*:=
"

# error: could not compile `rustc-serialize`
RESTRICT="test"
