# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Implements a selection of PCG random number generators."
HOMEPAGE="https://github.com/rust-random/rand"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/autocfg-0.1*:=
	~dev-rust/rand_core-0.4.0:=
	=dev-rust/serde-1*:=
	>=dev-rust/serde_derive-1.0.38:=
"

src_prepare() {
	cros-rust_src_prepare

	# Delete the bincode dev dependency. We don't use it. `cargo package`
	# insists that it exists, regardless of the fact that we don't use it.
	# Allowing the dependency introduces a circular dependency:
	# bincode -> byteorder -> rand -> rand_(rng) -> bincode
	sed -i '/\[dev-dependencies.bincode\]/{N;d;}' "${S}/Cargo.toml"
}
