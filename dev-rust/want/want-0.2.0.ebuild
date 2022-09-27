# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Detect when another Future wants a result."
HOMEPAGE="https://github.com/seanmonstar/want"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/futures-0.1:=
	>=dev-rust/log-0.4:=
	>=dev-rust/try-lock-0.2:=
"
