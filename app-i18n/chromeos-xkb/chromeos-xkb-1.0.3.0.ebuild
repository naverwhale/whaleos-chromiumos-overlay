# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the Apache License v2.

EAPI="7"

DESCRIPTION="The wrapping IME extension for xkb-based input methods"
HOMEPAGE="https://github.com/google/google-input-tools"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${PN}"

PATCHES=(
	"${FILESDIR}"/${P}-insert-pub-key.patch
)

src_install() {
	insinto /usr/share/chromeos-assets/input_methods/xkb
	doins -r ./*
}
