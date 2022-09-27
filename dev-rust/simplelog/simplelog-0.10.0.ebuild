# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A simple and easy-to-use logging facility for Rust's log crate"
HOMEPAGE="https://github.com/drakulix/simplelog.rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/chrono-0.4*:=
	=dev-rust/log-0.4*:=
	=dev-rust/termcolor-1.1*:=
"

# TODO(crbug.com/1182669): Remove this RDEPEND when fixed.
RDEPEND="${DEPEND}"
