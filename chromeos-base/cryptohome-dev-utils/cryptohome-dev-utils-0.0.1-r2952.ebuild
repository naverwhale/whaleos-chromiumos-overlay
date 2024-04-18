# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "b520c86fc47c2b608e00a037efae878907ffb1d0" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "585af077146f2e4daaaec14eb5814cd8507e862c" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
PYTHON_COMPAT=( python3_{8..11} )

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cryptohome libcrossystem libhwsec libhwsec-foundation secure_erase_file .gn"

PLATFORM_SUBDIR="cryptohome/dev-utils"

inherit python-any-r1 cros-workon platform

DESCRIPTION="Cryptohome developer and testing utilities for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/cryptohome"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE="test tpm tpm_dynamic tpm_insecure_fallback tpm2"

REQUIRED_USE="
	tpm_dynamic? ( tpm tpm2 )
	!tpm_dynamic? ( ?? ( tpm tpm2 ) )
"

# TODO(b/230430190): Remove shill-client dependency after experiment ended.
COMMON_DEPEND="
	tpm? (
		app-crypt/trousers:=
	)
	tpm2? (
		chromeos-base/trunks:=
	)
	chromeos-base/attestation:=
	chromeos-base/biod_proxy:=
	chromeos-base/bootlockbox-client:=
	chromeos-base/cbor:=
	chromeos-base/chaps:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/cryptohome:=
	chromeos-base/cryptohome-client:=
	chromeos-base/featured:=
	chromeos-base/libcrossystem:=[test?]
	chromeos-base/libhwsec:=
	chromeos-base/libhwsec-foundation:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/shill-client:=
	chromeos-base/system_api:=
	chromeos-base/tpm_manager:=
	chromeos-base/secure-erase-file:=
	dev-cpp/abseil-cpp:=
	dev-libs/flatbuffers:=
	dev-libs/glib:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
	sys-apps/keyutils:=
	sys-fs/e2fsprogs:=
	sys-fs/ecryptfs-utils:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/device_management-client:=
	chromeos-base/vboot_reference:=
"

# shellcheck disable=SC2016
BDEPEND="
	chromeos-base/chromeos-dbus-bindings
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
