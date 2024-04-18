# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

inherit cmake

DESCRIPTION="Perfetto-based OpenCL Kernel Profiler"
HOMEPAGE="https://github.com/rjodinchr/opencl-kernel-profiler"

CLKP_ARCHIVE_NAME="${PN}-de059691b1905bec6dc1c9cea743e0308feb9ee7"
CLKP_ARCHIVE="${CLKP_ARCHIVE_NAME}.zip"

SRC_URI="
gs://chromeos-localmirror/distfiles/${CLKP_ARCHIVE}
"

CMAKE_USE_DIR="${WORKDIR}/${CLKP_ARCHIVE_NAME}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="+perfetto"

RDEPEND="
	media-libs/clvk
	dev-libs/opencl-icd-loader
"
DEPEND="
	>=dev-util/opencl-headers-2023.02.06
	>=chromeos-base/perfetto-31.0
	${RDEPEND}
"

# Need to unpack the source archive.
BDEPEND="app-arch/unzip"

src_unpack() {
	unpack "${CLKP_ARCHIVE}"
	mkdir -p "${WORKDIR}/${P}"
}

src_configure() {
	append-lfs-flags
	local mycmakeargs=(
		-DOPENCL_HEADER_PATH="${ESYSROOT}/usr/"
		-DBACKEND=System
		-DPERFETTO_SDK_PATH="${ESYSROOT}/usr/include/perfetto/"
	)
	cmake_src_configure
}

src_install() {
	local OPENCL_DIR="/usr/local/opencl"
	dodir "${OPENCL_DIR}"
	exeinto "${OPENCL_DIR}"
	doexe "${BUILD_DIR}/lib${PN}.so"

	exeinto "/usr/local/bin"
	doexe "${CMAKE_USE_DIR}/chromeos-utils/${PN}.sh"
}
