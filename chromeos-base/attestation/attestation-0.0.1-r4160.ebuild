# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "db749a759fbf2f6525efd1913a59051ea7472796" "8ef158b5fb8274ea8a54f4513609096575a74ad9" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "fea40a8b93606b2fc977192b0be1108448fbcfe4" "0d345aa95a2088afd12e25fd820a24ad6fb19c4a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk attestation chaps libhwsec libhwsec-foundation metrics tpm_manager trunks .gn"

PLATFORM_SUBDIR="attestation"

inherit cros-workon libchrome platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/attestation/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cr50_onboard generic_tpm2 profiling test ti50_onboard tpm tpm_dynamic tpm2 tpm2_simulator"

REQUIRED_USE="
	tpm_dynamic? ( tpm tpm2 )
	!tpm_dynamic? ( ?? ( tpm tpm2 ) )
"

RDEPEND="
	tpm? (
		app-crypt/trousers:=
	)
	tpm2? (
		chromeos-base/trunks:=
	)
	chromeos-base/chaps:=
	chromeos-base/libhwsec:=[test?]
	chromeos-base/libhwsec-foundation:=
	chromeos-base/system_api:=[fuzzer?]
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/minijail:=
	chromeos-base/tpm_manager-client:=
	chromeos-base/attestation-client
	dev-libs/openssl:0=
	dev-libs/protobuf:=
	"

DEPEND="
	${RDEPEND}
	chromeos-base/vboot_reference:=
	tpm2? (
		chromeos-base/trunks:=[test?]
		chromeos-base/chromeos-ec-headers:=
	)
	"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
	dev-libs/protobuf
"

pkg_preinst() {
	# Create user and group for attestation.
	enewuser "attestation"
	enewgroup "attestation"
	# Create group for /mnt/stateful_partition/unencrypted/preserve.
	enewgroup "preserve"
}

src_install() {
	platform_src_install

	insinto /usr/include/attestation/common
	doins common/attestation_interface.h
	doins "${OUT}"/gen/attestation/common/print_attestation_ca_proto.h
	doins "${OUT}"/gen/attestation/common/print_interface_proto.h
	doins "${OUT}"/gen/attestation/common/print_keystore_proto.h

	# Install the generated dbus-binding for fake pca agent.
	# It does no harm to install the header even for non-test image build.
	insinto /usr/include/attestation/pca-agent/dbus_adaptors
	doins "${OUT}"/gen/include/attestation/pca-agent/dbus_adaptors/org.chromium.PcaAgent.h

	# Allow specific syscalls for profiling.
	# TODO (b/242806964): Need a better approach for fixing up the seccomp policy
	# related issues (i.e. fix with a single function call)
	if use profiling; then
		echo -e "\n# Syscalls added for profiling case only.\nmkdir: 1\nftruncate: 1\n" >> \
		"${D}/usr/share/policy/attestationd-seccomp.policy"
		echo -e "\n# Syscalls added for profiling case only.\nmkdir: 1\nftruncate: 1\n" >> \
		"${D}/usr/share/policy/pca_agentd-seccomp.policy"
	fi
}

platform_pkg_test() {
	platform test_all
}
