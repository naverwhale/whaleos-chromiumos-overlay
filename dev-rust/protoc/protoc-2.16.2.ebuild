# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Protobuf protoc command as API"
HOMEPAGE="https://github.com/stepancheg/rust-protobuf/protoc/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

# This is required for the actual protoc binary.
BDEPEND="dev-libs/protobuf"

DEPEND="
	=dev-rust/log-0*:=
"
