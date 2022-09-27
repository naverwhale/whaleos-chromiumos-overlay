# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Rayon-core represents the core, stable APIs of Rayon: join, scope, and so forth"
HOMEPAGE="https://github.com/rayon-rs/rayon"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/crossbeam-channel-0.5*:=
	=dev-rust/crossbeam-deque-0.8*:=
	=dev-rust/crossbeam-utils-0.8*:=
	=dev-rust/lazy_static-1*:=
	>=dev-rust/num_cpus-1.2:= <dev-rust/num_cpus-2.0
"

# could not compile
RESTRICT="test"
