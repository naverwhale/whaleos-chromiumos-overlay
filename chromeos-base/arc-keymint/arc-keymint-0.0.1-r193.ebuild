# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("ae07277fe7394cbb60e746d21d17f2f0a1ac163b" "316ee9015b661aae840f2668943eb697a9269643" "dcc518ef32993d0171d0849bd3677c9d0948f8bb" "9537e373c71c26c5495be60d267dff5eb88b180f" "2e909ccdf779939e5caa5ab52851f38f22037ae9" "2448b24d913368ed2a9e45141e12960992a8862e")
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "9e460cea0783689eb1e1588f5b4101da39da9b79" "4e673427662fbd8934f4e276e9b32113dc4771ed" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "1bbc2a3964e8e8350f97b9fdfaaba1220529ed20" "1a77f7f025502657540bbec1f57cbbb6478be4b4" "6fadd8addab8504349cdeefe51b583b97c2ae7f4" "ae1614ebb22b8aa59ecd0d29e1a0e162deaa2d09" "cb77643c93455808f15fc807c39d6aad34d1e473")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"platform/system/keymaster"
	"aosp/platform/system/core/libcutils"
	"aosp/platform/system/libbase"
	"aosp/platform/system/logging"
	"platform/system/libcppbor")

CROS_WORKON_REPO=(
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_AOSP_URL}"
	"${CROS_GIT_AOSP_URL}"
	"${CROS_GIT_AOSP_URL}"
	"${CROS_GIT_AOSP_URL}"
	"${CROS_GIT_AOSP_URL}"
)
# TODO(b/277630261): Finalize the branch points for projects.
CROS_WORKON_EGIT_BRANCH=(
	"master"
	"android13-platform-release"
	"master"
	"master"
	"master"
	"master")

CROS_WORKON_LOCALNAME=(
	"platform2"
	"aosp/system/keymint"
	"aosp/system/core/libcutils"
	"aosp/system/libbase"
	"aosp/system/logging"
	"aosp/system/libcppbor"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/aosp/system/keymint"
	"${S}/aosp/system/core/libcutils"
	"${S}/aosp/system/libbase"
	"${S}/aosp/system/logging"
	"${S}/aosp/system/libcppbor"
)

CROS_WORKON_SUBTREE=(
	"common-mk featured arc/keymint .gn"
	""
	""
	""
	""
	""
)

PLATFORM_SUBDIR="arc/keymint"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

# This BoringSSL integration follows go/boringssl-cros.
# DO NOT COPY TO OTHER PACKAGES WITHOUT CONSULTING SECURITY TEAM.
BORINGSSL_PN="boringssl"
BORINGSSL_PV="3a667d10e94186fd503966f5638e134fe9fb4080"
BORINGSSL_P="${BORINGSSL_PN}-${BORINGSSL_PV}"
BORINGSSL_OUTDIR="${WORKDIR}/boringssl_outputs/"

CMAKE_USE_DIR="${WORKDIR}/${BORINGSSL_P}"
BUILD_DIR="${WORKDIR}/${BORINGSSL_P}_build"

inherit flag-o-matic cmake cros-workon platform

DESCRIPTION="Android keymint service in Chrome OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/arc/keymint"
SRC_URI="https://github.com/google/${BORINGSSL_PN}/archive/${BORINGSSL_PV}.tar.gz -> ${BORINGSSL_P}.tar.gz"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="
	+seccomp
	keymint
"
# TODO(b/297420326): Since we use boringssl, we shouldn't depend on openssl.
RDEPEND="
	chromeos-base/chaps:=
	chromeos-base/cryptohome:=
	chromeos-base/cryptohome-client:=
	chromeos-base/featured:=
	chromeos-base/minijail:=
	dev-libs/protobuf:=
	acct-group/arc-keymintd
	acct-user/arc-keymintd
"

DEPEND="
	${RDEPEND}
	chromeos-base/session_manager-client:=
	chromeos-base/system_api:=
"

HEADER_TAINT="#ifdef CHROMEOS_OPENSSL_IS_OPENSSL
#error \"Do not mix OpenSSL and BoringSSL headers.\"
#endif
#define CHROMEOS_OPENSSL_IS_BORINGSSL\n"

src_unpack() {
	platform_src_unpack
	unpack "${BORINGSSL_P}.tar.gz"
	# Taint BoringSSL headers so they don't silently mix with OpenSSL.
	find "${BORINGSSL_P}/include/openssl" -type f -exec awk -i inplace -v \
		"taint=${HEADER_TAINT}" 'NR == 1 {print taint} {print}' {} \;
	(cd "${WORKDIR}/${BORINGSSL_P}" &&
		eapply "${FILESDIR}/boringssl-suppress-unused-but-set-variable.patch") || die
}

src_prepare() {
	cmake_src_prepare

	# Expose libhardware headers from arc-toolchain-p.
	local arc_arch="${ARCH}"
	# arm needs to use arm64 directory, which provides combined arm/arm64
	# headers.
	if [[ "${ARCH}" == "arm" ]]; then
		arc_arch="arm64"
	fi

	mkdir -p "${WORKDIR}/libhardware/include" || die

	cp -rfp "/opt/android-t/${arc_arch}/usr/include/hardware" "${WORKDIR}/libhardware/include" || die
	cp -rfp "/opt/android-t/${arc_arch}/usr/include/android-base" "${WORKDIR}/libhardware/include" || die
	cp -rfp "/opt/android-t/${arc_arch}/usr/include/cutils" "${WORKDIR}/libhardware/include" || die
	cp -rfp "/opt/android-t/${arc_arch}/usr/include/android" "${WORKDIR}/libhardware/include" || die
	cp -rfp "/opt/android-t/${arc_arch}/usr/include/log" "${WORKDIR}/libhardware/include" || die
	cp -rfp "/opt/android-t/${arc_arch}/usr/include/system" "${WORKDIR}/libhardware/include" || die

	append-cxxflags "-I${WORKDIR}/libhardware/include"

	# Expose BoringSSL headers and outputs.
	append-cxxflags "-I${WORKDIR}/${BORINGSSL_P}/include"
	append-ldflags "-L${BORINGSSL_OUTDIR}"
}

src_configure() {
	local mycmakeargs=(
		"-DCMAKE_BUILD_TYPE=Release"
		"-DCMAKE_SYSTEM_PROCESSOR=${CHOST%%-*}"
		"-DBUILD_SHARED_LIBS=OFF"
	)
	cmake_src_configure
	platform_src_configure
}

src_compile() {
	# The build is banned from accessing internet, thus turn off Go Modules
	# to prevent Go from trying to fetch package.
	export GO111MODULE=off
	# Compile BoringSSL and expose libcrypto.a.
	cmake_src_compile

	mkdir -p "${BORINGSSL_OUTDIR}" || die
	cp -p "${BUILD_DIR}/crypto/libcrypto.a" "${BORINGSSL_OUTDIR}/libboringcrypto.a" || die

	platform_src_compile
}

src_install() {
	platform_src_install

	# TODO(b/274723323):
	# Finalize fuzzers
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc-keymintd_testrunner"
}
