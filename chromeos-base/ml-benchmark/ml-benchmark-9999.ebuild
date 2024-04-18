# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
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
KEYWORDS="~*"
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
