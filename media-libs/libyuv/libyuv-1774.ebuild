# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-common.mk cros-debug

DESCRIPTION="YUV library"
HOMEPAGE="https://chromium.googlesource.com/libyuv/libyuv"
GIT_SHA1="fc61dde1eb4b7807201fa20cd0a7d023363558b2"
SRC_URI="https://chromium.googlesource.com/libyuv/libyuv/+archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="virtual/jpeg:0"

RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	default
	cp -a "${FILESDIR}"/* "${S}"/ || die
}

src_install() {
	insinto /usr/include
	doins -r include/*

	dolib.a libyuv.pic.a

	insinto /usr/$(get_libdir)/pkgconfig
	sed -e "s:@LIB@:$(get_libdir):g" libyuv.pc.in | newins - libyuv.pc
}
