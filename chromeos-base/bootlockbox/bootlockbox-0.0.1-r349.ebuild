# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "5bf947979813d481d14995861aa5ba98fa78f419" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk bootlockbox libhwsec libhwsec-foundation metrics .gn"

PLATFORM_SUBDIR="bootlockbox"

inherit cros-workon platform user

DESCRIPTION="BootLockbox service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/bootlockbox/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="fuzzer profiling systemd test tpm tpm2 tpm_dynamic"

RDEPEND="
	!<chromeos-base/cryptohome-0.0.2
	chromeos-base/bootlockbox-client:=
	chromeos-base/libhwsec:=[test?]
	chromeos-base/libhwsec-foundation:=
	chromeos-base/metrics:=
	chromeos-base/minijail:=
	chromeos-base/system_api:=[fuzzer?]
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/tpm_manager:=
	chromeos-base/vboot_reference:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
"

DEPEND="${RDEPEND}"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

src_install() {
	platform_src_install
	# Allow specific syscalls for profiling.
	# TODO (b/242806964): Need a better approach for fixing up the seccomp policy
	# related issues (i.e. fix with a single function call)
	if use profiling; then
		sed -i "/prctl:/d" "${D}/usr/share/policy/bootlockboxd-seccomp.policy" &&
		echo -e "\n# Syscalls added for profiling case only.\nmkdir: 1\nftruncate: 1\nprctl: 1\n" >> \
		"${D}/usr/share/policy/bootlockboxd-seccomp.policy"
	fi
}

pkg_preinst() {
	enewuser "bootlockboxd"
	enewgroup "bootlockboxd"
}

platform_pkg_test() {
	platform test_all
}
