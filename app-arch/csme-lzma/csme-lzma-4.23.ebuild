# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=6

DESCRIPTION="7-ZIP LZMA SDK with specific patches for Intel ME"
HOMEPAGE="https://www.7-zip.org/sdk.html"
SRC_URI="gs://chromeos-localmirror/distfiles/lzma${PV//.}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}/${P}-missing-include.patch"
	"${FILESDIR}/${P}-intel-3-bytes-padding.patch"
)

src_compile() {
	cd SRC/7zip/Compress/LZMA_Alone || die
	emake
}

src_install() {
	newbin SRC/7zip/Compress/LZMA_Alone/lzma "${PN}"
}
