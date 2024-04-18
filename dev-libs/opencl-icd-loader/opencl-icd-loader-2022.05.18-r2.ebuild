# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS="cmake"
inherit cmake-multilib

MY_PN="OpenCL-ICD-Loader"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Official Khronos OpenCL ICD Loader"
HOMEPAGE="https://github.com/KhronosGroup/OpenCL-ICD-Loader"
SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RESTRICT="!test? ( test )"

DEPEND=">=dev-util/opencl-headers-2021.04.29
	!dev-libs/ocl-icd"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

multilib_src_configure() {
	append-lfs-flags

	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DOPENCL_ICD_LOADER_HEADERS_DIR="${ESYSROOT}/usr/include"
		# ChromeOS default opencl library is coming from clvk. To avoid
		# collision, install OpenCL ICD Loader in /usr/local/opencl/.
		-DCMAKE_INSTALL_PREFIX="/usr/local/opencl"
	)
	cmake_src_configure
}

multilib_src_test() {
	OCL_ICD_FILENAMES="${BUILD_DIR}/test/driver_stub/libOpenCLDriverStub.so" \
	cmake_src_test
}
