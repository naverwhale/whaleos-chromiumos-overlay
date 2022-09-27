# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Stable implemntation of the upcoming 'proc_macro' API"
HOMEPAGE="https://github.com/alexcrichton/proc-macro2"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/unicode-xid-0.1:=
"

# ---- test_debug_tokenstream stdout ----
# thread 'test_debug_tokenstream' panicked at 'assertion failed: `(left == right)`
#  left: `"TokenStream [\n    Group {\n        delimiter: Bracket,\n        stream: TokenStream [\n            Ident {\n                sym: a\n            },\n            Punct {\n                op: \'+\',\n                spacing: Alone\n            },\n            Literal {\n                lit: 1\n            }\n        ]\n    }\n]"`,
# right: `"TokenStream [\n    Group {\n        delimiter: Bracket,\n        stream: TokenStream [\n            Ident {\n                sym: a,\n            },\n            Punct {\n                op: \'+\',\n                spacing: Alone,\n            },\n            Literal {\n                lit: 1,\n            },\n        ],\n    },\n]"`', tests/test.rs:382:5
RESTRICT="test"
