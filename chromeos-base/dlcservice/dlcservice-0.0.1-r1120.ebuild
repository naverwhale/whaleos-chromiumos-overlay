# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "a6eaa2daa397f15118a3806021521977bc7d1146" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid #include-ing platform2 headers directly.
CROS_WORKON_SUBTREE="common-mk dlcservice metrics .gn"

PLATFORM_SUBDIR="dlcservice"

inherit cros-workon platform tmpfiles udev user

DESCRIPTION="A D-Bus service for Downloadable Content (DLC)"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/dlcservice/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="
	fuzzer
	lvm_stateful_partition
"

RDEPEND="
	chromeos-base/dlcservice-metadata:=
	chromeos-base/imageloader:=
	lvm_stateful_partition? ( chromeos-base/lvmd:= )
	chromeos-base/minijail:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	dev-libs/protobuf:=
	sys-apps/rootdev:=
	sys-libs/zlib:=
"

DEPEND="${RDEPEND}
	chromeos-base/dlcservice-client:=
	chromeos-base/imageloader-client:=
	lvm_stateful_partition? ( chromeos-base/lvmd-client:= )
	chromeos-base/system_api:=[fuzzer?]
	chromeos-base/update_engine-client:=
	chromeos-base/vboot_reference:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

src_install() {
	platform_src_install

	# Install all the udev rules.
	udev_dorules "${FILESDIR}"/udev/*.rules

	dosbin "${OUT}/dlcservice"
	# Technically we don't need the dlcservice_util in rootfs, but the QA team
	# will need this to test with sample-dlc.
	dobin "${OUT}/dlcservice_util"

	# Seccomp policy files.
	insinto /usr/share/policy
	newins "seccomp/dlcservice-seccomp-${ARCH}.policy" \
		dlcservice-seccomp.policy

	# Upstart configuration
	insinto /etc/init
	doins dlcservice.conf

	# Tmpfiles.d configuration
	dotmpfiles tmpfiles.d/*.conf

	# D-Bus configuration
	insinto /etc/dbus-1/system.d
	doins org.chromium.DlcService.conf

	local fuzzer_component_id="908242"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/dlcservice_boot_device_fuzzer \
		--comp "${fuzzer_component_id}"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/dlcservice_boot_slot_fuzzer \
		--comp "${fuzzer_component_id}"

	into /usr/local
	dobin "${S}/tools/dlctool"
	dobin "${OUT}/dlc_metadata_util"
	dobin "${OUT}/dlcverify"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/dlcservice_tests"
}

pkg_preinst() {
	enewuser "dlcservice"
	enewgroup "dlcservice"
	enewgroup "disk-dlc" # For DLC logical volume management.
}
