# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT=("1b3b0251dc4647859163e426f9e6ee4e2e60fd71" "0f43a2a7bd66ebae38b48de549299cfe4a5ebbe8")
CROS_WORKON_TREE=("da966c6555ba69addced173cec1cef4d8c33ff68" "c1498662b51dd4d020ebbd7b0f7c3c0fb37fcfdf")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/clvk"
	"chromiumos/third_party/clspv"
)

CROS_WORKON_LOCALNAME=(
	"clvk"
	"clspv"
)

CLVK_DIR="${S}/clvk"
CLSPV_DIR="${S}/clspv"

CROS_WORKON_DESTDIR=(
	"${CLVK_DIR}"
	"${CLSPV_DIR}"
)

CROS_WORKON_EGIT_BRANCH=(
	"upstream/main"
	"upstream/main"
)

inherit cros-sanitizers cmake cros-workon

CMAKE_USE_DIR="${CLVK_DIR}"

DESCRIPTION="Experimental implementation of OpenCL 3.0 on Vulkan"
HOMEPAGE="https://github.com/kpet/clvk"

LLVM_FOLDER="llvm-project-9bcf9dc98a6829ae3b0b18aa82368def394af7f4"
LLVM_ARCHIVE="${LLVM_FOLDER}.zip"

SRC_URI="gs://chromeos-localmirror/distfiles/${LLVM_ARCHIVE}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="debug +perfetto"

VK_SPV_VERSION="1.3.261"

# target runtime dependencies
RDEPEND="
	>=dev-util/spirv-tools-${VK_SPV_VERSION}
	>=media-libs/vulkan-loader-${VK_SPV_VERSION}
	virtual/vulkan-icd
	app-arch/zstd
	chromeos-base/perfetto:=
	sys-libs/ncurses
	sys-libs/zlib
"

# target build dependencies
DEPEND="
	>=dev-util/vulkan-headers-${VK_SPV_VERSION}
	>=dev-util/spirv-headers-${VK_SPV_VERSION}-r1
	>=dev-util/opencl-headers-2023.02.06
	${RDEPEND}
"

# host build dependencies
BDEPEND="
	app-arch/unzip
"

[[ ${PV} != "9999" ]] && PATCHES=(
	"${FILESDIR}/clvk-00-GITHUB-PR-609-image1d_buffer.patch"
	"${FILESDIR}/clvk-01-BGRA_fixup.patch"
	"${FILESDIR}/clvk-02-GITHUB-PR-614-3D_images_unorm_sampler.patch"
	"${FILESDIR}/clvk-03-image_format_feature_flags_RO.patch"
	"${FILESDIR}/clvk-04-GITHUB-PR-621-dynamic_batches.patch"
	"${FILESDIR}/clvk-05-GITHUB-PR-622-remove_fabs_from_intel_and_AMD.patch"
	"${FILESDIR}/clvk-06-GITHUB-PR-526-multi_command_event.patch"

	# TODO(b/259217927) : To be remove as soon as they are merged upstream
	"${FILESDIR}/clvk-90-timeline-semaphores.patch"
	"${FILESDIR}/clvk-91-configurable-polling.patch"
	"${FILESDIR}/clvk-92-enable_dyn_batches.patch"
)

src_unpack() {
	unpack "${LLVM_ARCHIVE}"
	cros-workon_src_unpack
}

src_prepare() {
	cmake_src_prepare
	eapply_user

	# ChromeOS: do not set -fno-rtti with sanitizers enabled.
	if use_sanitizers ; then
		sed -i 's/ -fno-rtti//g' "${S}/clspv/CMakeLists.txt" || die
	fi
}

build_host_tools() {
	[[ "$#" -eq 2 ]] \
		|| die "build_host_tools called with the wrong number of arguments"
	local HOST_DIR="$1"
	local LLVM_DIR="$2"

	# Use host toolchain when building for the host.
	local CC=${CBUILD}-clang
	local CXX=${CBUILD}-clang++
	local CFLAGS=''
	local CXXFLAGS=''
	local LDFLAGS=''

	mkdir -p "${HOST_DIR}" || die

	cd "${HOST_DIR}" || die
	cmake \
		-DLLVM_TARGETS_TO_BUILD="" \
		-DLLVM_OPTIMIZED_TABLEGEN=ON \
		-DLLVM_INCLUDE_BENCHMARKS=OFF \
		-DLLVM_INCLUDE_EXAMPLES=OFF \
		-DLLVM_INCLUDE_TESTS=OFF \
		-DLLVM_ENABLE_BINDINGS=OFF \
		-DLLVM_ENABLE_UNWIND_TABLES=OFF \
		-DLLVM_BUILD_TOOLS=OFF \
		-G "Unix Makefiles" \
		-DLLVM_ENABLE_PROJECTS="clang" \
		-DCMAKE_BUILD_TYPE=Release \
		"${LLVM_DIR}" || die

	cd "${HOST_DIR}/utils/TableGen" || die
	emake
	[[ -x "${HOST_DIR}/bin/llvm-tblgen" ]] \
		|| die "${HOST_DIR}/bin/llvm-tblgen not found or usable"

	cd "${HOST_DIR}/tools/clang/utils/TableGen" || die
	emake
	[[ -x "${HOST_DIR}/bin/clang-tblgen" ]] \
		|| die "${HOST_DIR}/bin/clang-tblgen not found or usable"
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug Debug RelWithDebInfo)

	local CLVK_LLVM_PROJECT_DIR="${WORKDIR}/${LLVM_FOLDER}"
	local mycmakeargs=(
		-DSPIRV_HEADERS_SOURCE_DIR="${ESYSROOT}/usr/"
		-DSPIRV_TOOLS_SOURCE_DIR="${ESYSROOT}/usr/"

		-DLLVM_INCLUDE_BENCHMARKS=OFF
		-DLLVM_INCLUDE_EXAMPLES=OFF
		-DLLVM_INCLUDE_TESTS=OFF
		-DLLVM_ENABLE_BINDINGS=OFF
		-DLLVM_ENABLE_UNWIND_TABLES=OFF
		-DLLVM_BUILD_TOOLS=OFF

		-DCLSPV_SOURCE_DIR="${CLSPV_DIR}"
		-DCLSPV_LLVM_SOURCE_DIR="${CLVK_LLVM_PROJECT_DIR}/llvm"
		-DCLSPV_CLANG_SOURCE_DIR="${CLVK_LLVM_PROJECT_DIR}/clang"

		-DCLVK_CLSPV_ONLINE_COMPILER=1
		-DCLVK_ENABLE_SPIRV_IL=OFF

		-DCLSPV_BUILD_SPIRV_DIS=OFF
		-DCLSPV_BUILD_TESTS=OFF
		-DCLVK_BUILD_TESTS=OFF
		-DCLVK_BUILD_SPIRV_TOOLS=OFF

		-DCLVK_VULKAN_IMPLEMENTATION=system

		-DCMAKE_MODULE_PATH="${CMAKE_MODULE_PATH};${CLVK_LLVM_PROJECT_DIR}/llvm/cmake/modules"

		-DBUILD_SHARED_LIBS=OFF

		-DCLVK_PERFETTO_ENABLE=$(usex perfetto ON OFF)
		-DCLVK_PERFETTO_LIBRARY=perfetto_sdk
		-DCLVK_PERFETTO_BACKEND=System
		-DCLVK_PERFETTO_SDK_DIR="${ESYSROOT}/usr/include/perfetto/"

		-DCLVK_ENABLE_ASSERTIONS=$(usex debug ON OFF)
	)

	if tc-is-cross-compiler; then
		local HOST_DIR="${WORKDIR}/host_tools"
		build_host_tools "${HOST_DIR}" "${CLVK_LLVM_PROJECT_DIR}/llvm"
		mycmakeargs+=(
			-DCMAKE_CROSSCOMPILING=ON
			-DLLVM_TABLEGEN="${HOST_DIR}/bin/llvm-tblgen"
			-DCLANG_TABLEGEN="${HOST_DIR}/bin/clang-tblgen"
		)
	fi

	cmake_src_configure
}

src_install() {
	dolib.so "${BUILD_DIR}/libOpenCL.so"*
}
