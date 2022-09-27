# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
inherit cros-rust

DESCRIPTION="Beautiful diagnostic reporting for text-based programming languages"
HOMEPAGE="https://github.com/brendanzab/codespan"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="Apache-2.0"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/termcolor-1*:=
	=dev-rust/unicode-width-0.1*:=
	=dev-rust/serde-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/syn-1*:=
"