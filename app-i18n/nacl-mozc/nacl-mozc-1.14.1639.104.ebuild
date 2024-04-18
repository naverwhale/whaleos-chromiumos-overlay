# Copyright 2013 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="The Mozc engine for IME extension API"
HOMEPAGE="https://github.com/google/mozc"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nacl-mozc-${PV}.tgz"

LICENSE="BSD-Google"
IUSE=""
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_prepare() {
	default

	cd ${PN}-*/ || die

	# Removes unused NaCl binaries.
	if ! use arm && ! use arm64; then
		rm nacl_session_handler_arm.nexe || die
	fi
	if ! use x86 ; then
		rm nacl_session_handler_x86_32.nexe || die
	fi
	if ! use amd64 ; then
		rm nacl_session_handler_x86_64.nexe || die
	fi

	# Inserts the public key to manifest.json.
	# The key is used to execute NaCl Mozc as a component extension.
	# NaCl Mozc is handled as id:bbaiamgfapehflhememkfglaehiobjnk.
	eapply "${FILESDIR}"/${P}-insert-oss-public-key.patch
}

src_install() {
	cd ${PN}-*/ || die

	insinto /usr/share/chromeos-assets/input_methods/nacl_mozc
	doins -r ./*
}
