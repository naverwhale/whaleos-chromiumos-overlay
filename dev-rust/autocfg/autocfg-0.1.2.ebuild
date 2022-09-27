# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A Rust library for build scripts to automatically configure code based on compiler support"
HOMEPAGE="https://github.com/cuviper/autocfg"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

# thread 'tests::probe_as_ref' panicked at 'called `Result::unwrap()` on an `Err` value: Error { kind: Io(Os { code: 2, kind: NotFound, message: "No such file or directory" }) }', src/tests.rs:35:42
RESTRICT="test"
