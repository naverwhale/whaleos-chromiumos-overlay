# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic unpacker

DESCRIPTION="Intel OpenVino Toolkit"
HOMEPAGE="https://github.com/openvinotoolkit/openvino"
GIT_HASH="a4a1bff1cc5a6b22f806adac8845d2806772dacd"
GIT_SHORT_HASH=${GIT_HASH::8}

# This tarball needs to be manually created due to the use of submodules. Downloading
#   -> https://github.com/openvinotoolkit/openvino/archive/${GIT_HASH}.tar.gz
# wouldn't work because it will not contain the submodules.
#
# Steps to reproduce tarball:
# $ git clone https://github.com/openvinotoolkit/openvino.git
# $ cd openvino
# $ git checkout ${GIT_HASH}
# $ git submodule init
# $ git submodule update
# $ rm -rf .git
# $ cd ..
# $ tar -Jcvf intel-openvino-${GIT_SHORT_HASH}.tar.xz openvino

SRC_URI="gs://chromeos-localmirror/distfiles/intel-openvino-${GIT_SHORT_HASH}.tar.xz"

LICENSE="Apache-2.0"
KEYWORDS="-* amd64"
IUSE="+clang"
SLOT="0"

S="${WORKDIR}/openvino"

RDEPEND="
	chromeos-base/intel-gnalib
"

DEPEND="
	${RDEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/0001-Disable-samples.patch"
	cros_enable_cxx_exceptions
	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	cros_enable_cxx_exceptions
	append-flags "-frtti -msse4.2"
	CPPFLAGS="-I${S}/ngraph/src -I${S}/inference_engine/ngraph_ops ${CPPFLAGS}"
	CMAKE_BUILD_TYPE="Release"

	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DENABLE_CLDNN=OFF
		-DENABLE_GNA=ON
		-DGNA_LIBRARY_VERSION=GNA2
		-DENABLE_NGRAPH=OFF
		-DTHREADING=SEQ
		-DENABLE_MKL_DNN=OFF
		-DGNA_DIR="gna"
		-DTARGET_OS="CHROMEOS"
		-DENABLE_OPENCV=OFF
		-DENABLE_SAMPLES=OFF
		-DCMAKE_INSTALL_PREFIX="/usr/local"
		-DBUILD_SHARED_LIBS=ON
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/libinference_engine.so
	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/libinference_engine_nn_builder.so
	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/libinference_engine_preproc.so
	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/libGNAPlugin.so
	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/libinference_engine_c_api.so
	dolib.so "${D}"/usr/local/deployment_tools/inference_engine/lib/intel64/plugins.xml
}
