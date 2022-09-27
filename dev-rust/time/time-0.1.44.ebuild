# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Utilities for working with time-related functions in Rust."
HOMEPAGE="https://github.com/rust-lang/time"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libc-0.2.1:=
	>=dev-rust/log-0.4.0:=
	>=dev-rust/redox_syscall-0.1.0:=
	>=dev-rust/wasi-0.10.0:=
	>=dev-rust/winapi-0.3.0:=
	>=dev-rust/rustc-serialize-0.3.0:=
"
