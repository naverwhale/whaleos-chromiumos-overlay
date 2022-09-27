# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Procedural macros to make inter-operation between primitives and enums easier."
HOMEPAGE="https://github.com/illicitonion/num_enum"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="BSD"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/derivative-2*:=
	>=dev-rust/num_enum_derive-0.5.1:= <dev-rust/num_enum_derive-0.6.0
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	!=dev-rust/num_enum-5*
"

RESTRICT="test"
