# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Parse command line arguments by defining a struct."
HOMEPAGE="https://github.com/TeXitoi/structopt"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/clap-2.33.0:= <dev-rust/clap-3
	>=dev-rust/lazy_static-1.4.0:= <dev-rust/lazy_static-2.0.0
	=dev-rust/structopt-derive-0.4.13:=
	=dev-rust/paw-1*:=
"

# error: could not compile `structopt`
RESTRICT="test"
