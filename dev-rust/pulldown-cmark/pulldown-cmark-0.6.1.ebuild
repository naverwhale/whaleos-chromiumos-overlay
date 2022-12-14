# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='A pull parser for CommonMark'
HOMEPAGE='https://crates.io/crates/pulldown-cmark'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bitflags-1.2.0:= <dev-rust/bitflags-2.0.0
	=dev-rust/getopts-0.2*:=
	>=dev-rust/memchr-2.2.0:= <dev-rust/memchr-3.0.0
	>=dev-rust/unicase-2.5.0:= <dev-rust/unicase-3.0.0
"

RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# Testing has a large dependency graph, mostly because of `html5ever` and
# `markup5ever` it requires. The graph contains a lot of packages not available
# in ChromiumOS repositories.
RESTRICT="test"
