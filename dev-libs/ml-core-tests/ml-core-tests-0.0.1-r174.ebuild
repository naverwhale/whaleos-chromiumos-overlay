# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "cceb75d9e5555d3cccb273c52847819feabc9c65" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk ml_core .gn"

DESCRIPTION="Tests for Chrome OS ML Core Feature Library"

PLATFORM_SUBDIR="ml_core/tests"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon platform

# camera_feature_effects needed as `use.camera_feature_effects` is
# referenced in BUILD.gn
IUSE="camera_feature_effects"
LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
	dev-libs/ml-core:=
	media-libs/libpng:=
	chromeos-base/dlcservice:=
	chromeos-base/dlcservice-client:=
"

DEPEND="${RDEPEND}
"

src_install() {
	platform_src_install

	insinto /usr/local/
	dobin "${OUT}"/ml_core_effects_pipeline_test

	insinto /usr/local/share/ml_core
	doins -r testdata/*.png
}

platform_pkg_test() {
	local tests=(
		ml_core_pngio_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
