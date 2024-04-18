# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_BUILD_TYPE="Release"

CROS_WORKON_COMMIT="29da856483658d15afdbf92d4e3db7794fac7470"
CROS_WORKON_TREE="8acbf0fcaac7fe95e9d24adcffa872a92650cebf"
CROS_WORKON_PROJECT="chromiumos/third_party/gmmlib"
CROS_WORKON_MANUAL_UPREV="1"
CROS_WORKON_LOCALNAME="gmmlib"
CROS_WORKON_EGIT_BRANCH="chromeos"

inherit cmake cros-workon

DESCRIPTION="Intel Graphics Memory Management Library"
HOMEPAGE="https://github.com/intel/gmmlib"

KEYWORDS="*"
LICENSE="MIT"
SLOT="0/12.1"
IUSE="+custom-cflags test"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}"/${PN}-20.2.2_conditional_testing.patch
	"${FILESDIR}"/${PN}-20.3.2_cmake_project.patch
	"${FILESDIR}"/${PN}-22.1.1_custom_cflags.patch
	"${FILESDIR}"/0001-BACKPORT-Add-more-device-IDs-for-RPL.patch
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING="$(usex test)"
		-DBUILD_TYPE="Release"
		-DOVERRIDE_COMPILER_FLAGS="$(usex !custom-cflags)"
	)

	cmake_src_configure
}
