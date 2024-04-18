# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

inherit cmake

DESCRIPTION="Serialization format for persistent Vulkan object types."
HOMEPAGE="https://github.com/ValveSoftware/Fossilize"

# See go/uprev-fossilize for instructions on how to update these hashes.

GIT_REV="f7c28e337fecb9608e462409f192c456ac47fa6d"

SPIRV_CROSS_GIT_REV="5e963d62fa3f2f0ff891c9f9ca150097127c3aad"
SPIRV_HEADERS_GIT_REV="fc7d2462765183c784a0c46beb13eee9e506a067"
SPIRV_TOOLS_GIT_REV="a996591b1c67e789e88e99ae3881272f5fc47374"
DIRENT_GIT_REV="c885633e126a3a949ec0497273ec13e2c03e862c"
VOLK_GIT_REV="65e811e401bc09a9525265aea584db898d67e54f"
RAPIDJSON_GIT_REV="8f4c021fa2f1e001d2376095928fc0532adf2ae6"

SRC_URI="
https://github.com/ValveSoftware/Fossilize/archive/${GIT_REV}.tar.gz -> fossilize-${GIT_REV}.tar.gz
https://github.com/KhronosGroup/SPIRV-Cross/archive/${SPIRV_CROSS_GIT_REV}.tar.gz -> SPIRV-Cross-${SPIRV_CROSS_GIT_REV}.tar.gz
https://github.com/KhronosGroup/SPIRV-Headers/archive/${SPIRV_HEADERS_GIT_REV}.tar.gz -> SPIRV-Headers-${SPIRV_HEADERS_GIT_REV}.tar.gz
https://github.com/KhronosGroup/SPIRV-Tools/archive/${SPIRV_TOOLS_GIT_REV}.tar.gz -> SPIRV-Tools-${SPIRV_TOOLS_GIT_REV}.tar.gz
https://github.com/tronkko/dirent/archive/${DIRENT_GIT_REV}.tar.gz -> dirent-${DIRENT_GIT_REV}.tar.gz
https://github.com/zeux/volk/archive/${VOLK_GIT_REV}.tar.gz -> volk-${VOLK_GIT_REV}.tar.gz
https://github.com/miloyip/rapidjson/archive/${RAPIDJSON_GIT_REV}.tar.gz -> rapidjson-${RAPIDJSON_GIT_REV}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	media-libs/vulkan-loader
	virtual/vulkan-icd
"
DEPEND="
	dev-util/vulkan-headers
"

FOSSILIZE_ROOT_DIR="${WORKDIR}/Fossilize-${GIT_REV}"
S="${FOSSILIZE_ROOT_DIR}"

src_unpack() {
	default

	pushd "${FOSSILIZE_ROOT_DIR}" || die
	mv -T "../SPIRV-Cross-${SPIRV_CROSS_GIT_REV}" cli/SPIRV-Cross || die
	mv -T "../SPIRV-Headers-${SPIRV_HEADERS_GIT_REV}" cli/SPIRV-Headers \
		|| die
	mv -T "../SPIRV-Tools-${SPIRV_TOOLS_GIT_REV}" cli/SPIRV-Tools || die
	mv -T "../dirent-${DIRENT_GIT_REV}" cli/dirent || die
	mv -T "../volk-${VOLK_GIT_REV}" cli/volk || die
	mv -T "../rapidjson-${RAPIDJSON_GIT_REV}" rapidjson || die
	popd || die
}

src_configure() {
	append-flags -Wno-unqualified-std-cast-call
	cros_enable_cxx_exceptions
	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/cli/fossilize-replay"
}
