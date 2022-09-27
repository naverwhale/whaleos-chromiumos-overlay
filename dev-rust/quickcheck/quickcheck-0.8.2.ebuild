# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="QuickCheck is a way to do property based testing using randomly generated input"
HOMEPAGE="https://github.com/BurntSushi/quickcheck"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Unlicense )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/rand-0.6.5:=
	=dev-rust/rand_core-0.4*:=
	=dev-rust/env_logger-0.6*:=
	=dev-rust/log-0.4*:=
"
