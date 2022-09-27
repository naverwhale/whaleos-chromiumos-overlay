# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Generate JUnit compatible XML reports in Rust."
HOMEPAGE="https://github.com/bachp/junit-report-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/chrono-0.4.11:= <dev-rust/chrono-0.5.0
	=dev-rust/derive-getters-0.1*:=
	>=dev-rust/thiserror-1.0.19:= <dev-rust/thiserror-2
	>=dev-rust/xml-rs-0.8.3:= <dev-rust/xml-rs-0.9
"
