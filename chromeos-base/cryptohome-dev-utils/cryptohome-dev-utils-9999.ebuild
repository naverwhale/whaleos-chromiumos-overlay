# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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
KEYWORDS="~*"
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
