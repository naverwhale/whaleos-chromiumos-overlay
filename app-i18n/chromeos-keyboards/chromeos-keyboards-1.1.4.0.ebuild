# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the Apache License v2.

EAPI="7"

DESCRIPTION="The Google Input Tools (keyboard part) based on IME Extension API"
HOMEPAGE="https://github.com/google/google-input-tools"
# TODO: Change the $PF to $P.
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}-r6.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${PN}"

PATCHES=(
	"${FILESDIR}"/${P}-insert-pub-key-private-api.patch
)

src_install() {
	insinto /usr/share/chromeos-assets/input_methods/keyboard_layouts
	doins -r ./*
}
