# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_BUILD_TYPE="Release"

CROS_WORKON_PROJECT="chromiumos/third_party/gmmlib"
CROS_WORKON_MANUAL_UPREV="1"
CROS_WORKON_LOCALNAME="gmmlib"
CROS_WORKON_EGIT_BRANCH="chromeos"

inherit cmake cros-workon

DESCRIPTION="Intel Graphics Memory Management Library"
HOMEPAGE="https://github.com/intel/gmmlib"

KEYWORDS="~*"
LICENSE="MIT"
SLOT="0/12.1"
IUSE="+custom-cflags test"
RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
		-DBUILD_TYPE="Release"
		-DOVERRIDE_COMPILER_FLAGS="$(usex !custom-cflags)"
	)

	cmake_src_configure
}
