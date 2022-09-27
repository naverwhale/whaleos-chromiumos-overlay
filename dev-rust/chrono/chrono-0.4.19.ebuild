# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Aims to be a feature-complete superset of the time library"
HOMEPAGE="https://github.com/chronotope/chrono"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bincode-0.8*:=
	>=dev-rust/num-integer-0.1.36:= <dev-rust/num-integer-0.2.0
	>=dev-rust/num-iter-0.1.35:= <dev-rust/num-iter-0.2.0
	=dev-rust/num-traits-0.2*:=
	>=dev-rust/rustc-serialize-0.3.20:= <dev-rust/rustc-serialize-0.4.0
	=dev-rust/serde-1*:=
	=dev-rust/serde_derive-1*:=
	=dev-rust/serde_json-1*:=
	>=dev-rust/time-0.1.43:= <dev-rust/time-0.2.0
"
RDEPEND="${DEPEND}"

# error: no matching package named `pure-rust-locales` found
RESTRICT="test"
