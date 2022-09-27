# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A library for querying the version of a rustc compiler"
HOMEPAGE="https://github.com/Kimundi/rustc-version-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/semver-0.9*:=
"

# thread 'smoketest' panicked at 'called `Result::unwrap()` on an `Err` value: CouldNotExecuteCommand(Os { code: 2, kind: NotFound, message: "No such file or directory" })', src/lib.rs:202:23
RESTRICT="test"
