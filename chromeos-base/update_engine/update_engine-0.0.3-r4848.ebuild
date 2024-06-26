# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("28855525b6c452b8822c99272354f0aece775a5d" "da666b88e04d1d0367588080de9d9762a91b6cd6")
CROS_WORKON_TREE=("a6eaa2daa397f15118a3806021521977bc7d1146" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "affefe346d8087890123b2751018ebaca8e2735f")
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/update_engine")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/update_engine")
CROS_WORKON_EGIT_BRANCH=("main" "master")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/update_engine")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=("dlcservice common-mk .gn" "")

PLATFORM_SUBDIR="update_engine"
# Tests use /dev/loop*.
PLATFORM_HOST_DEV_TEST="yes"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-debug cros-workon platform systemd

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="https://chromium.googlesource.com/aosp/platform/system/update_engine/"
SRC_URI=""

LICENSE="Apache-2.0"
KEYWORDS="*"
IUSE="cfm cros_host cros_p2p dlc fuzzer hibernate hw_details -hwid_override lvm_stateful_partition minios +power_management report_requisition systemd test"

COMMON_DEPEND="
	app-arch/brotli:=
	app-arch/bzip2:=
	chromeos-base/chromeos-ca-certificates:=
	dlc? ( chromeos-base/dlcservice:= )
	hw_details? (
		chromeos-base/diagnostics:=
		chromeos-base/mojo_service_manager:=
	)
	chromeos-base/imageloader:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/libcrossystem:=[test?]
	chromeos-base/oobe_config:=[test?]
	chromeos-base/vboot_reference:=
	cros_p2p? ( chromeos-base/p2p:= )
	dev-libs/expat:=
	dev-libs/libdivsufsort:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	dev-libs/xz-embedded:=
	dev-util/bsdiff:=
	dev-util/puffin:=
	net-misc/curl:=
	sys-apps/rootdev:=
	sys-fs/e2fsprogs:=
"

CLIENT_DEPEND="
	chromeos-base/debugd-client:=
	dlc? ( chromeos-base/dlcservice-client:= )
	chromeos-base/imageloader-client:=
	chromeos-base/power_manager-client:=
	chromeos-base/session_manager-client:=
	chromeos-base/shill-client:=
	chromeos-base/update_engine-client:=
	hibernate? ( chromeos-base/hiberman-client:= )
"

DEPEND="
	app-arch/xz-utils:=
	chromeos-base/system_api:=[fuzzer?]
	test? ( sys-fs/squashfs-tools )
	${CLIENT_DEPEND}
	${COMMON_DEPEND}
"

DELTA_GENERATOR_RDEPEND="
	app-arch/unzip:=
	app-arch/xz-utils:=
	|| (
		>=sys-fs/e2fsprogs-1.46.4-r5:=
		sys-libs/e2fsprogs-libs:=
	)
	sys-fs/squashfs-tools
"

RDEPEND="
	!cros_host? (
		chromeos-base/chromeos-installer
		virtual/update-policy:=
	)
	${CLIENT_DEPEND}
	${COMMON_DEPEND}
	cros_host? (
		${DEPEND}
		${DELTA_GENERATOR_RDEPEND}
	)
	power_management? ( chromeos-base/power_manager:= )
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	dev-libs/protobuf
"

platform_pkg_test() {
	local unittests_binary="${OUT}"/update_engine_unittests

	# The unittests will try to exec `./helpers`, so make sure we're in
	# the right dir to execute things.
	cd "${OUT}" || die
	# The tests also want keys to be in the current dir.
	# .pub.pem files are generated on the "gen" directory.
	cp "${S}"/unittest_key*.pem ./ || die
	cp gen/include/update_engine/unittest_key*.pub.pem ./ || die

	# The unit tests check to make sure the minor version value in
	# update_engine.conf match the constants in update engine, so we need to be
	# able to access this file.
	cp "${S}/update_engine.conf" ./

	# If GTEST_FILTER isn't provided, we run two subsets of tests
	# separately: the set of non-privileged  tests (run normally)
	# followed by the set of privileged tests (run as root).
	# Otherwise, we pass the GTEST_FILTER environment variable as
	# an argument and run all the tests as root; while this might
	# lead to tests running with excess privileges, it is necessary
	# in order to be able to run every test, including those that
	# need to be run with root privileges.
	if [[ -z "${GTEST_FILTER}" ]]; then
		platform_test "run" "${unittests_binary}" 0 '-*.RunAsRoot*'
		platform_test "run" "${unittests_binary}" 1 '*.RunAsRoot*'
	else
		platform_test "run" "${unittests_binary}" 1 "${GTEST_FILTER}"
	fi
}

src_install() {
	platform_src_install

	insinto /etc
	newins update_engine.conf.chromeos update_engine.conf

	if use systemd; then
		systemd_dounit "${FILESDIR}"/update-engine.service
		systemd_enable_service multi-user.target update-engine.service
	else
		# Install upstart script
		insinto /etc/init
		doins init/update-engine.conf
	fi

	# Install DBus configuration
	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	# TODO(b/182168271): Remove minios flag and public key from update_engine.
	# Add the public key only when signing for MiniOs.
	if use minios; then
		insinto "/build/initramfs"
		doins scripts/update_payload/update-payload-key.pub.pem
	fi

	local fuzzer_component_id="908319"
	platform_fuzzer_install "${S}"/OWNERS \
				"${OUT}"/update_engine_omaha_request_action_fuzzer \
				--dict "${S}"/fuzz/xml.dict \
				--comp "${fuzzer_component_id}"
	platform_fuzzer_install "${S}"/OWNERS \
				"${OUT}"/update_engine_delta_performer_fuzzer \
				--comp "${fuzzer_component_id}"
}
