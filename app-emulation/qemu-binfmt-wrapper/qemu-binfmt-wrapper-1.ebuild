# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit toolchain-funcs

DESCRIPTION="QEMU wrappers to preserve argv[0] when testing"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}

src_compile() {
	$(tc-getCC) \
		-Wall -Wextra -Werror \
		${CFLAGS} \
		${CPPFLAGS} \
		${LDFLAGS} \
		"${FILESDIR}"/${PN}.c \
		-o ${PN} \
		-static
}

src_install() {
	dobin ${PN}
}
