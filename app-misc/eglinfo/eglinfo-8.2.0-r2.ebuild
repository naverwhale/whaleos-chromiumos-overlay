# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MY_PN=mesa-demos
MY_P=${MY_PN}-${PV}
EGIT_REPO_URI="git://anongit.freedesktop.org/${MY_PN/-//}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
fi

inherit base toolchain-funcs ${GIT_ECLASS}

DESCRIPTION="eglinfo from Mesa demos"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ ${PV} == 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/${MY_PN/-//}/${PV}/${MY_P}.tar.bz2"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="virtual/opengles"
DEPEND="${RDEPEND}
	x11-drivers/opengles-headers
	x11-libs/libX11
"

S=${WORKDIR}/${MY_P}
EGIT_CHECKOUT_DIR=${S}

src_unpack() {
	default
	[[ $PV = 9999* ]] && git-r3_src_unpack
}

src_configure() { :; }

src_compile() {
	cd src/egl/opengl
	$(tc-getCC) ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -o ${PN} ${PN}.c -lEGL
}

src_install() {
	dobin src/egl/opengl/eglinfo
}
