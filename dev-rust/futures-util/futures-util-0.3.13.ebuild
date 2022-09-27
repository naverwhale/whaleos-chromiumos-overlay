# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Common utilities and extension traits for the futures-rs library."
HOMEPAGE="https://github.com/rust-lang-nursery/futures-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/futures-channel-0.3.13:= <dev-rust/futures-channel-0.4
	>=dev-rust/futures-core-0.3.13:= <dev-rust/futures-core-0.4
	>=dev-rust/futures-io-0.3.13:= <dev-rust/futures-io-0.4
	>=dev-rust/futures-macro-0.3.13:= <dev-rust/futures-macro-0.4
	>=dev-rust/futures-sink-0.3.13:= <dev-rust/futures-sink-0.4
	>=dev-rust/futures-task-0.3.13:= <dev-rust/futures-task-0.4
	>=dev-rust/memchr-2.2:= <dev-rust/memchr-3.0
	>=dev-rust/pin-utils-0.1.0_alpha4:= <dev-rust/pin-utils-0.2
	>=dev-rust/pin-project-lite-0.2.4_alpha4:= <dev-rust/pin-project-lite-0.3
	>=dev-rust/proc-macro-hack-0.5.19:= <dev-rust/proc-macro-hack-0.6
	>=dev-rust/proc-macro-nested-0.1.2:= <dev-rust/proc-macro-nested-0.2
	>=dev-rust/slab-0.4.2:= <dev-rust/slab-1.0
"
# This DEPEND was removed to break a circular dependency.
#   ">=dev-rust/tokio-io-0.1.9:= <dev-rust/tokio-io-0.2"
# It is needed if the io-compat feature is set, an empty crate is substituted to
# avoid breaking ebuilds that depend on futures-util but do not set io-compat.
DEPEND+="~dev-rust/tokio-io-0.1.9"
RDEPEND="
	${DEPEND}
	!~dev-rust/${PN}-0.3.1
"

# error: no matching package named `futures` found
RESTRICT="test"
