# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic unpacker

DESCRIPTION="Intel GNA library for Gemini Lake and Tiger Lake"
HOMEPAGE="https://github.com/intel/gna"
GIT_HASH="6e42dc7a53fff9d7e644ea48dac70c841c72a14b"
GIT_SHORT_HASH=${GIT_HASH::8}
SRC_URI="https://github.com/intel/gna/archive/${GIT_HASH}.tar.gz -> intel-gna-${GIT_SHORT_HASH}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="-* amd64"
IUSE="+clang"
SLOT="0"

S="${WORKDIR}/gna-${GIT_HASH}"

RDEPEND="${DEPEND}"

src_prepare() {
	eapply "${FILESDIR}/0001-Enable-changes-needed-for-ChromeOS-build.patch"
	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	cros_enable_cxx_exceptions
	append-flags "-fvisibility=default"
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DTARGET_OS="ChromeOS"
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	cp -fpru "${CMAKE_USE_DIR}"/bin/gna-lib/LNX-RELEASE/x64/libgna.so.2.0.0.0 "${WORKDIR}"
	cp -fpru "${CMAKE_USE_DIR}"/bin/gna-lib/LNX-RELEASE/x64/libgna.so.2 "${WORKDIR}"
	cp -fpru "${CMAKE_USE_DIR}"/bin/gna-lib/LNX-RELEASE/x64/libgna.so "${WORKDIR}"
	cp -fpru "${S}"/bin/gna-lib/include "${WORKDIR}"
	cp -fpru "${S}"/src/common/gna*.h "${WORKDIR}"/include
}

src_install() {
	dolib.so "${WORKDIR}"/libgna.so.2.0.0.0
	dolib.so "${WORKDIR}"/libgna.so.2
	dolib.so "${WORKDIR}"/libgna.so
	insinto "/usr/include"
	doins "${WORKDIR}"/include/*
}
