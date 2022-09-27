# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Logger that aims to provide a simple case of env_logger that just logs to stderr based on verbosity"
HOMEPAGE="https://github.com/cardoe/stderrlog-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/atty-0.2.6:= <dev-rust/atty-0.3.0
	>=dev-rust/chrono-0.4.10:= <dev-rust/chrono-0.5.0
	>=dev-rust/log-0.4.11:= <dev-rust/log-0.5.0
	>=dev-rust/termcolor-1.1:= <dev-rust/termcolor-1.2
	>=dev-rust/thread_local-1.0:= <dev-rust/thread_local-1.1
"

RDEPEND="${DEPEND}"
