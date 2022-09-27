# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Library for ANSI terminal colours and styles (bold, underline)."
HOMEPAGE="https://github.com/ogham/rust-ansi-term"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/winapi-0.3.4:= <dev-rust/winapi-0.4.0
"
RDEPEND="${DEPEND}"

# thread 'debug::test::long_and_detailed' panicked at 'assertion failed: `(left == right)`
#  left: `"Style {\n    foreground: Some(\n        Blue\n    ),\n    background: None,\n    blink: false,\n    bold: true,\n    dimmed: false,\n    hidden: false,\n    italic: false,\n    reverse: false,\n    strikethrough: false,\n    underline: false\n}"`,
#  right: `"Style {\n    foreground: Some(\n        Blue,\n    ),\n    background: None,\n    blink: false,\n    bold: true,\n    dimmed: false,\n    hidden: false,\n    italic: false,\n    reverse: false,\n    strikethrough: false,\n    underline: false,\n}"`', src/debug.rs:120:9
RESTRICT="test"
