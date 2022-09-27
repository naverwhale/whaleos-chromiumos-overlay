# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Extensions to the standard library's networking types, proposed in RFC 1158"
HOMEPAGE="https://github.com/rust-lang-nursery/net2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cfg-if-0.1*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/winapi-0.3*:=
"
