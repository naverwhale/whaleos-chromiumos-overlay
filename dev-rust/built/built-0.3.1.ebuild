# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="built provides a crate with information from the time it was built."
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="=dev-rust/toml-0.5*:=
	=dev-rust/chrono-0.4*:=
	=dev-rust/git2-0.9*:=
	=dev-rust/semver-0.9*:=
	=dev-rust/tempdir-0.3*:=
"

# thread 'new_testbox' panicked at 'called `Option::unwrap()` on a `None` value', tests/testbox_tests.rs:63:58
RESTRICT="test"
