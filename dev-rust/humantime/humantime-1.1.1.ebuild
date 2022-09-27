# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Human-friendly time parser and formatter."
HOMEPAGE="https://github.com/tailhook/humantime"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/quick-error-1*:=
	=dev-rust/chrono-0.4*:=
	=dev-rust/rand-0.4*:=
	>=dev-rust/time-0.1.39:=
"
