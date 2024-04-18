# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "fea40a8b93606b2fc977192b0be1108448fbcfe4" "4c1c10db2b3b0754b1c85ba64b32a41a374d782e" "0d345aa95a2088afd12e25fd820a24ad6fb19c4a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
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
KEYWORDS="*"
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
