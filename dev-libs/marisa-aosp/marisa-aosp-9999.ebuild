# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="MARISA: Matching Algorithm with Recursively Implemented StorAge (AOSP fork)"
HOMEPAGE="https://android.googlesource.com/platform/external/marisa-trie/"

CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk .gn"

PLATFORM_SUBDIR="marisa-trie"

EGIT_REPO_URI="https://android.googlesource.com/platform/external/marisa-trie/"
EGIT_CHECKOUT_DIR="${S}/platform2/marisa-trie/"

if [[ ${PV} != *9999* ]]; then
	EGIT_COMMIT="54417d28a5273a8d759b28882a0c96335e192756"
fi

inherit cros-workon git-r3 platform

LICENSE="BSD-2 LGPL-2.1 BSD-Google"
SLOT="0"
KEYWORDS="~*"

IUSE=""
REQUIRED_USE=""

# To warn future developers that this is the AOSP fork of marisa.
POSTFIX="-aosp"

src_unpack() {
	platform_src_unpack
	git-r3_src_unpack
}

src_prepare() {
	default
	cp "${FILESDIR}/BUILD.gn" "${S}"
}

src_install() {
	mv "${OUT}/libmarisa.a" "${OUT}/libmarisa${POSTFIX}.a"
	dolib.a "${OUT}/libmarisa${POSTFIX}.a"

	# Install the header files to /usr/include/marisa-trie/.
	insinto "/usr/include/marisa${POSTFIX}"
	doins "${S}/include/marisa.h"
	insinto "/usr/include/marisa${POSTFIX}/marisa"
	local f
	for f in \
		"include/marisa/agent.h" \
		"include/marisa/base.h" \
		"include/marisa/exception.h" \
		"include/marisa/iostream.h" \
		"include/marisa/key.h" \
		"include/marisa/keyset.h" \
		"include/marisa/query.h" \
		"include/marisa/scoped-array.h" \
		"include/marisa/scoped-ptr.h" \
		"include/marisa/stdio.h" \
		"include/marisa/trie.h"; do
		doins "${S}/${f}"
	done
}
