# Copyright 2015 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic multilib toolchain-funcs

DESCRIPTION="Small XZ decompressor"
HOMEPAGE="https://tukaani.org/xz/embedded.html"
SRC_URI="https://tukaani.org/xz/xz-embedded-${PV}.tar.gz"

# See top-level COPYING file for the license description.
LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	default
	cp "${FILESDIR}"/{Makefile,xz-embedded.pc.in} "${S}" || die "Copying files"
}

src_configure() {
	# Enable support for BCJ filters for the common architectures. See other
	# available architectures in userspace/xz_config.h.
	append-cppflags -DXZ_DEC_X86 -DXZ_DEC_ARM -DXZ_DEC_ARMTHUMB

	export GENTOO_LIBDIR=$(get_libdir)
	tc-export AR CC
}
