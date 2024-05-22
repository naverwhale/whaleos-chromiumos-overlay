# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_PROJECT="chromiumos/third_party/clvk"

CROS_WORKON_LOCALNAME="clvk"

CLVK_DIR="${S}/clvk"

CROS_WORKON_DESTDIR="${CLVK_DIR}"

CROS_WORKON_EGIT_BRANCH="upstream/main"

inherit cmake cros-workon

CMAKE_USE_DIR="${CLVK_DIR}/tests"

DESCRIPTION="Experimental implementation of OpenCL 3.0 on Vulkan"
HOMEPAGE="https://github.com/kpet/clvk"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"
IUSE="debug"

# target runtime dependencies
RDEPEND="
	media-libs/clvk
	>=dev-cpp/gtest-1.10.0
"

# target build dependencies
DEPEND="
	>=dev-util/opencl-headers-2023.02.06
	${RDEPEND}
"

[[ ${PV} != "9999" ]] && PATCHES=(
	# We need this patch because of the early submit feature introduced by the
	# vkSemaphore based implementation (clvk-90-timeline-semaphores.patch).
	"${FILESDIR}/clvk-api_tests-profiling.patch"
)

src_prepare() {
	cmake_src_prepare
	eapply_user
}

src_configure() {
	local mycmakeargs=(
		-DCLVK_VULKAN_IMPLEMENTATION=system
		-DCLVK_COMPILER_AVAILABLE=ON
		-DBUILD_SHARED_LIBS=OFF
		-DCLVK_BUILD_STATIC_TESTS=OFF
		-DCLVK_GTEST_LIBRARIES="gtest;gtest_main"
		-DCMAKE_CXX_STANDARD_LIBRARIES="-lpthread" # needed for api_tests
	)
	cmake_src_configure
}

src_install() {
	local OPENCL_TESTS_DIR="/usr/local/opencl"
	dodir "${OPENCL_TESTS_DIR}"
	exeinto "${OPENCL_TESTS_DIR}"
	doexe "${BUILD_DIR}/api_tests" "${BUILD_DIR}/simple_test"
}
