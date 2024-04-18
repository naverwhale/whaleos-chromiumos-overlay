# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="The Korean Hangul input engine for IME extension API"
HOMEPAGE="https://github.com/google/google-input-tools"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

src_prepare() {
	default

	# Removes unused NaCl binaries.
	if ! use arm && ! use arm64; then
		rm hangul_arm.nexe || die
	fi
	if ! use x86 ; then
		rm hangul_x86_32.nexe || die
	fi
	if ! use amd64 ; then
		rm hangul_x86_64.nexe || die
	fi
}

src_install() {
	insinto /usr/share/chromeos-assets/input_methods/hangul
	doins -r ./*
}
