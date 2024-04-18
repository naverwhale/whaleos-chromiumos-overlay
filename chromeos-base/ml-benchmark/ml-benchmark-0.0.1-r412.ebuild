# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "75f23f887e8c461c47ba7a054257780b41216a35" "725701adb1b6a3ba6dcf4d54de479337b517e5d1" "cceb75d9e5555d3cccb273c52847819feabc9c65" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
# ml and ml_core for building libml_for_benchmark.so.
CROS_WORKON_SUBTREE="common-mk ml ml_benchmark ml_core .gn"

DESCRIPTION="Chrome OS ML Benchmarking Suite"

PLATFORM_SUBDIR="ml_benchmark"
# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon platform

# chromeos-base/ml_benchmark blocked due to package rename
RDEPEND="
	chromeos-base/dlcservice-client:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	!chromeos-base/ml_benchmark
	chromeos-base/system_api:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	vulkan? ( media-libs/clvk )
	sci-libs/tensorflow:=
"

DEPEND="${RDEPEND}"

BDEPEND="dev-libs/protobuf"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="ml_benchmark_drivers vulkan"

src_install() {
	platform_src_install

	if use ml_benchmark_drivers; then
		insinto /usr/local/ml_benchmark/ml_service
		insopts -m0755
		doins "${OUT}"/lib/libml_for_benchmark.so
		insopts -m0644
	fi
}

platform_pkg_test() {
	platform test_all
}
