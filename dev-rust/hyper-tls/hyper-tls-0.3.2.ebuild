# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Default TLS implementation for use with hyper"
HOMEPAGE="https://github.com/hyperium/hyper-tls"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	>=dev-rust/futures-0.1.21:= <dev-rust/futures-0.2.0
	=dev-rust/hyper-0.12*:=
	=dev-rust/native-tls-0.2*:=
	=dev-rust/tokio-io-0.1*:=
"
RDEPEND="${DEPEND}"
