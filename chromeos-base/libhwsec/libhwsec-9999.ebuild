# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libcrossystem libhwsec libhwsec-foundation metrics tpm_manager tpm2-simulator trunks .gn"

PLATFORM_SUBDIR="libhwsec"

inherit python-any-r1 cros-workon platform

DESCRIPTION="Crypto and utility functions used in TPM related daemons."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libhwsec/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="test fuzzer tpm tpm2 tpm_dynamic"

COMMON_DEPEND="
	chromeos-base/chromeos-ec-headers:=
	chromeos-base/libhwsec-foundation:=
	chromeos-base/metrics:=
	chromeos-base/system_api:=
	chromeos-base/tpm_manager-client:=
	chromeos-base/libcrossystem:=[test?]
	dev-cpp/abseil-cpp:=
	dev-libs/openssl:0=
	dev-libs/flatbuffers:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	tpm2? (
		chromeos-base/pinweaver:=
		chromeos-base/trunks:=[test?]
	)
	tpm? ( app-crypt/trousers:= )
	fuzzer? (
		app-crypt/trousers:=
		chromeos-base/trunks:=
	)
	test? (
		app-crypt/trousers:=
		chromeos-base/pinweaver:=
		chromeos-base/trunks:=[test]
		chromeos-base/tpm2-simulator:=[test]
	)
"

RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

# shellcheck disable=SC2016
BDEPEND="
	dev-libs/flatbuffers
	dev-libs/protobuf
	$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
		dev-python/flatbuffers[${PYTHON_USEDEP}]
	')
"

python_check_deps() {
	python_has_version -b "dev-python/jinja[${PYTHON_USEDEP}]" &&
		python_has_version -b "dev-python/flatbuffers[${PYTHON_USEDEP}]"
}

platform_pkg_test() {
	platform test_all
}

src_install() {
	platform_src_install

	local fuzzer_component_id="1188704"

	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/libhwsec_tpm1_cmk_migration_parser_fuzzer \
		--comp "${fuzzer_component_id}"

	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/libhwsec_tpm2_backend_fuzzer \
		--comp "${fuzzer_component_id}" \
		--dict "${S}"/fuzzers/testdata/tpm2_commands.dict
}
