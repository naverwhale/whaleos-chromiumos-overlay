# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Official FlexBuffers Rust runtime library."
HOMEPAGE="https://google.github.io/flatbuffers/flexbuffers"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="Apache-2.0"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bitflags-1.2.1 <dev-rust/bitflags-2:=
	>=dev-rust/byteorder-1.3.2 <dev-rust/byteorder-2:=
	=dev-rust/num_enum-0.5*:=
	>=dev-rust/serde-1.0.114 <dev-rust/serde-2:=
	=dev-rust/serde_derive-1*:=
"
RDEPEND="${DEPEND}"
