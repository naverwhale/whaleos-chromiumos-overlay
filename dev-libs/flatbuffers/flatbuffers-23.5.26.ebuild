# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic

DESCRIPTION="Memory efficient serialization library"
HOMEPAGE="
	https://flatbuffers.dev/
	https://github.com/google/flatbuffers/
"
SRC_URI="
	https://github.com/google/flatbuffers/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="static-libs test"
RESTRICT="!test? ( test )"

src_configure() {
	# ChromeOS: TODO file upstream bug
	append-lfs-flags

	local mycmakeargs=(
		-DFLATBUFFERS_CPP_STD=20 # ChromeOS uses C++20.
		-DFLATBUFFERS_BUILD_FLATLIB=$(usex static-libs)
		-DFLATBUFFERS_BUILD_SHAREDLIB=ON
		-DFLATBUFFERS_BUILD_TESTS=$(usex test)
		-DFLATBUFFERS_BUILD_BENCHMARKS=OFF
	)

	cmake_src_configure
}
