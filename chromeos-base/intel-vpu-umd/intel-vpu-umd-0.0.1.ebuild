# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the MIT License

EAPI=7

inherit cmake flag-o-matic unpacker

DESCRIPTION="Intel(R) Versatile Processing Unit User-mode driver"
HOMEPAGE="https://github.com/intel/linux-vpu-driver"
VPU_UMD_GIT_HASH="aa2163dc785580b0363710b789768d0a64bb8bb6"
VPU_L0_GIT_HASH="107c3ad5c2911cce2dc999cc53771adef96be03a"
VPU_ONEAPI_L0_GIT_HASH="474188ae004a5c76953a829477997bc341e70d48"
VPU_PLUGIN_ELF_GIT_HASH="268f141e098cd0239e8889c52270deb9e7322e68"

SRC_URI="gs://chromeos-localmirror/distfiles/intel-vpu-umd-0.0.1-files.tar.xz
	gs://chromeos-localmirror/distfiles/intel-linux-vpu-driver-${VPU_UMD_GIT_HASH}.tar.gz
	gs://chromeos-localmirror/distfiles/intel-level-zero-vpu-extensions-${VPU_L0_GIT_HASH}.tar.gz
	gs://chromeos-localmirror/distfiles/level-zero-${VPU_ONEAPI_L0_GIT_HASH}.tar.gz
	gs://chromeos-localmirror/distfiles/openvinotoolkit-vpux-plugin-elf-${VPU_PLUGIN_ELF_GIT_HASH}.tar.gz"


RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="+clang vpu_driver"

S="${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}"

DEPEND="
	dev-libs/boost
"

RDEPEND="${DEPEND}"

CMAKE_BUILD_TYPE="Release"

src_unpack() {
	unpack ${DISTDIR}/intel-linux-vpu-driver-${VPU_UMD_GIT_HASH}.tar.gz
	rmdir  ${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}/umd/third_party/*
	unpack ${DISTDIR}/intel-level-zero-vpu-extensions-${VPU_L0_GIT_HASH}.tar.gz
	mv "${WORKDIR}/level-zero-vpu-extensions-${VPU_L0_GIT_HASH}" ${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}/umd/third_party/level-zero-vpu-extensions
	unpack ${DISTDIR}/level-zero-${VPU_ONEAPI_L0_GIT_HASH}.tar.gz
	mv "${WORKDIR}/level-zero-${VPU_ONEAPI_L0_GIT_HASH}" ${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}/umd/third_party/level-zero
	unpack ${DISTDIR}/openvinotoolkit-vpux-plugin-elf-${VPU_PLUGIN_ELF_GIT_HASH}.tar.gz
	mv "${WORKDIR}/vpux_plugin_elf-${VPU_PLUGIN_ELF_GIT_HASH}" ${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}/umd/third_party/vpux_elf
	cp "${FILESDIR}/VERSION_PATCH"  ${WORKDIR}/linux-vpu-driver-${VPU_UMD_GIT_HASH}/umd/third_party/level-zero
}

src_prepare() {
	cros_enable_cxx_exceptions
	eapply_user
	unpack ${DISTDIR}/$P-files.tar.xz
	cmake_src_prepare
}

src_configure() {
	cros_enable_cxx_exceptions

	local mycmakeargs=(
		-DSKIP_UNIT_TESTS=ON
		-DENABLE_VPUX_COMPILER=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use vpu_driver ; then
		dolib.so ${BUILD_DIR}/lib/libze_intel_vpu.so.1.1.0
		dosym libze_intel_vpu.so.1.1.0 /usr/$(get_libdir)/libze_intel_vpu.so.1
		dosym libze_intel_vpu.so.1 /usr/$(get_libdir)/libze_intel_vpu.so

		dolib.so ${BUILD_DIR}/lib/libze_loader.so.1.8.5
		dosym libze_loader.so.1.8.5 /usr/$(get_libdir)/libze_loader.so.1
		dosym libze_loader.so.1 /usr/$(get_libdir)/libze_loader.so

		insinto /lib/firmware
		doins "${S}"/fw/mtl_vpu_v0.0.bin
		dosym mtl_vpu_v0.0.bin /lib/firmware/mtl_vpu.bin
	fi
}
