# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "3aea7ab9227cc5744eec929795d28a7ce91caae2" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk debugd metrics .gn"

PLATFORM_SUBDIR="debugd"

inherit cros-workon platform user

DESCRIPTION="Chrome OS debugging service"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/debugd/"
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="arcvm cellular iwlwifi_dump nvme sata tpm ufs"

COMMON_DEPEND="
	app-arch/xz-utils:=
	chromeos-base/chromeos-login:=
	chromeos-base/cryptohome-client:=
	chromeos-base/minijail:=
	chromeos-base/metrics:=
	chromeos-base/power_manager-client:=
	chromeos-base/shill-client:=
	chromeos-base/system_api:=
	chromeos-base/vboot_reference:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	net-libs/libpcap:=
	net-wireless/iw:=
	sys-apps/rootdev:=
	sys-libs/libcap:=
	sata? ( sys-apps/smartmontools:= )
"
RDEPEND="${COMMON_DEPEND}
	iwlwifi_dump? ( chromeos-base/intel-wifi-fw-dump )
	nvme? ( sys-apps/nvme-cli )
	ufs? (
		sys-apps/sg3_utils
		sys-apps/ufs-utils
	)
	chromeos-base/chromeos-ssh-testkeys
	chromeos-base/chromeos-sshd-init
	chromeos-base/libsegmentation
	!chromeos-base/workarounds
	sys-apps/iproute2
	sys-apps/memtester
"
DEPEND="${COMMON_DEPEND}
	chromeos-base/debugd-client:=
	sys-apps/dbus:="

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
	dev-libs/protobuf
"

pkg_setup() {
	# Has to be done in pkg_setup() instead of pkg_preinst() since
	# src_install() needs debugd.
	enewuser "debugd"
	enewgroup "debugd"

	cros-workon_pkg_setup
}

pkg_preinst() {
	enewuser "debugd-logs"
	enewgroup "debugd-logs"

	enewgroup "daemon-store"
	enewgroup "logs-access"
}

src_install() {
	platform_src_install

	local debugd_seccomp_dir="src/helpers/seccomp"
	# Install seccomp policies.
	insinto /usr/share/policy
	local policy
	for policy in "${debugd_seccomp_dir}"/*-"${ARCH}".policy; do
		local policy_basename="${policy##*/}"
		local policy_name="${policy_basename/-${ARCH}}"
		newins "${policy}" "${policy_name}"
	done

	# Install DBus configuration.
	insinto /etc/dbus-1/system.d
	doins share/org.chromium.debugd.conf

	insinto /etc/init
	doins share/debugd.conf share/kernel-features.json

	insinto /etc/perf_commands
	doins -r share/perf_commands/*

	local daemon_store="/etc/daemon-store/debugd"
	dodir "${daemon_store}"
	fperms 0660 "${daemon_store}"
	fowners debugd:debugd "${daemon_store}"

	local fuzzer_component_id="960619"
	platform_fuzzer_install "${S}"/OWNERS \
			"${OUT}"/debugd_cups_uri_helper_utils_fuzzer \
			--comp "${fuzzer_component_id}"
}

platform_pkg_test() {
	platform test_all
	pushd "${S}/src" >/dev/null || die
	./helpers/capture_utility_test.sh || die
	popd >/dev/null || die
}
