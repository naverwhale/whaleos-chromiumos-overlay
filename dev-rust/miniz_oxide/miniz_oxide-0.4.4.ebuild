# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="DEFLATE compression and decompression library rewritten in Rust based on miniz"
HOMEPAGE="https://github.com/Frommi/miniz_oxide/tree/master/miniz_oxide"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT ZLIB Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/adler-1.0:= <dev-rust/adler-2
"
