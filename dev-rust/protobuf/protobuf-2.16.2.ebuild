# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Rust implementation of Google protocol buffers"
HOMEPAGE="https://github.com/stepancheg/rust-protobuf/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.5*:=
	=dev-rust/serde-1*:=
	=dev-rust/serde_derive-1*:=
"
