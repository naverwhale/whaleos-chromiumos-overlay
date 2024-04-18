# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT=("04097b9df3be67662e26f4a7452ddbf989a7158b" "1e7a836627664f80fc83188d0a5c9405b8d26727")
CROS_WORKON_TREE=("e25747d84e1e5bb28342114bcceca2f823218dbc" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "0dd1a6e4665a8683c327f6193f5cdaf6e768e402" "76da3dc7374cc7573368173b8aea30665e865e83")
CROS_WORKON_INCREMENTAL_BUILD=1

CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/dev-util"
)
CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/dev"
)
CROS_WORKON_SUBTREE=(
	".clang-format common-mk chromeos-config .gn power_manager"
	"test/gtest"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/dev"
)
PLATFORM_SUBDIR="chromeos-config"

inherit cros-workon platform gtest

DESCRIPTION="Chrome OS configuration tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/chromeos-config"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

GTEST_METADATA=(
	libcros_config/cros_config_functional_test.yaml
)

GTEST_TEST_INSTALL_DIR="/usr/local/gtest/cros_config"

DEPEND="${RDEPEND}"

src_install() {
	platform_src_install

	dolib.so "${OUT}/lib/libcros_config.so"

	insinto "/usr/include/chromeos/chromeos-config/libcros_config"
	doins "${S}"/libcros_config/*.h

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libcros_config.pc

	insinto "/usr/include/cros_config"
	doins "libcros_config/cros_config_interface.h"
	doins "libcros_config/cros_config.h"
	doins "libcros_config/fake_cros_config.h"

	dobin "${OUT}"/cros_config
	newbin cros_config_mock.sh cros_config_mock

	if use test; then
		exeinto "${GTEST_TEST_INSTALL_DIR}"
		doexe  "${OUT}/cros_config_functional_test"

		install_gtest_metadata "${GTEST_METADATA[@]}"
	fi
}

platform_pkg_test() {
	local tests=(
		fake_cros_config_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
	./run_tests.sh || die "cros_config unit tests have errors"
}
