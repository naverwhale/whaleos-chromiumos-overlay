# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("ae07277fe7394cbb60e746d21d17f2f0a1ac163b" "70f29ed06f63e9711e07708d8713281e6b332504" "84c38b6e3978ab7391ab1a2a696bfd4627401097")
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "7d8a35364d50ee1a9de8310de0cf331759e94e73" "0a19f3a7d964bb9c758c96e942eddf3ec8c127fa")
inherit cros-constants

CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"aosp/platform/frameworks/ml"
	"aosp/platform/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_REPO=(
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
)
CROS_WORKON_EGIT_BRANCH=(
	"main"
	"master"
	"master"
)
CROS_WORKON_LOCALNAME=(
	"platform2"
	"aosp/frameworks/ml"
	"aosp/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform2/aosp/frameworks/ml"
	"${S}/platform2/aosp/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_SUBTREE=(
	"common-mk .gn"
	""
	""
)
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="aosp/frameworks/ml/chromeos/tests"

inherit cros-workon platform flag-o-matic

DESCRIPTION="HAL / Driver Vendor and Compatability Test Tools for NNAPI"
HOMEPAGE="https://developer.android.com/ndk/guides/neuralnetworks"

LICENSE="BSD-Google Apache-2.0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/aosp-frameworks-ml-nn:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/minijail:=
	chromeos-base/nnapi:=
	dev-cpp/abseil-cpp:=
	dev-cpp/gtest:=
	dev-libs/openssl:0=
	dev-libs/re2:=
	net-dns/c-ares:=
	net-libs/grpc:=
	sys-libs/zlib:=
"

DEPEND="
	${RDEPEND}
	dev-libs/libtextclassifier:=
"

src_configure() {
	# This warning is triggered in tensorflow.
	# See this Tensorflow PR for a fix:
	# https://github.com/tensorflow/tensorflow/pull/59040
	append-flags "-Wno-unused-but-set-variable"
	platform_src_configure
}

src_install() {
	platform_src_install

	dobin "${OUT}/cros_nnapi_vts_1_0"
	dobin "${OUT}/cros_nnapi_vts_1_1"
	dobin "${OUT}/cros_nnapi_vts_1_2"
	dobin "${OUT}/cros_nnapi_vts_1_3"
	dobin "${OUT}/cros_nnapi_vts_aidl"
	dobin "${OUT}/cros_nnapi_cts"
}
