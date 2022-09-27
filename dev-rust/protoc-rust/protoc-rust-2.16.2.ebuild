# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="protoc --rust_out=... available as API."
HOMEPAGE="https://github.com/stepancheg/rust-protobuf/protoc-rust/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="0/${PVR}"
KEYWORDS="*"

DEPEND="
	~dev-rust/protobuf-${PV}:=
	~dev-rust/protobuf-codegen-${PV}:=
	~dev-rust/protoc-${PV}:=
	=dev-rust/tempfile-3*:=
"
