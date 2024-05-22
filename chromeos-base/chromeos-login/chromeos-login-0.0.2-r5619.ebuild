# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="28855525b6c452b8822c99272354f0aece775a5d"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "709a41e5e595b1ec20189cdc9912091ca7d8e048" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "083569b82e5bcbfefd8700a2cd52ea619e712f7a" "c47d2f74e4533459b52db08fa32145d212c1fe8c" "04af2f1005707115b755acd5276795815a335d6b" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(b/187784160): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chromeos-config libcontainer libcrossystem libpasswordprovider login_manager libsegmentation metrics .gn"

PLATFORM_SUBDIR="login_manager"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit tmpfiles cros-workon cros-unibuild platform systemd user

DESCRIPTION="Login manager for Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/login_manager/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="apply_landlock_policy arc_adb_sideloading cheets flex_id fuzzer
	+apply_landlock_policy +login_apply_no_new_privs login_enable_crosh_sudo systemd test
	user_session_isolation"

COMMON_DEPEND="chromeos-base/bootstat:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/minijail:=
	chromeos-base/cryptohome:=
	chromeos-base/libchromeos-ui:=
	chromeos-base/libcontainer:=
	chromeos-base/libcrossystem:=[test?]
	chromeos-base/libpasswordprovider:=
	chromeos-base/libsegmentation:=[test?]
	>=chromeos-base/metrics-0.0.1-r3152:=
	dev-libs/nspr:=
	dev-libs/nss:=
	dev-libs/protobuf:=
	fuzzer? ( dev-libs/libprotobuf-mutator:= )
	sys-apps/dbus:=
	sys-apps/util-linux:=
"

RDEPEND="${COMMON_DEPEND}
	acct-group/session_manager
	acct-user/session_manager
	flex_id? ( chromeos-base/flex_id:= )
"

DEPEND="${COMMON_DEPEND}
	>=chromeos-base/protofiles-0.0.43:=
	chromeos-base/system_api:=[fuzzer?]
	chromeos-base/vboot_reference:=
	test? (
		dev-util/shunit2
		sys-process/procps
		sys-process/lsof
	)
"

BDEPEND="
	app-crypt/nss
	chromeos-base/chromeos-dbus-bindings
	dev-libs/protobuf
"

pkg_preinst() {
	enewgroup policy-readers
}

platform_pkg_test() {
	local tests=( session_manager_test )

	# Qemu doesn't support signalfd currently, and it's not clear how
	# feasible it is to implement :(.
	# So, filter out the tests that rely on signalfd().
	local gtest_qemu_filter=""
	if ! use x86 && ! use amd64; then
		gtest_qemu_filter+="-ChildExitHandlerTest.*"
		gtest_qemu_filter+=":SessionManagerProcessTest.*"
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "0" "" "${gtest_qemu_filter}"
	done

	if use x86 || use amd64; then
		platform_test "run" "./init/scripts/ui-killers-helper_unittest"
	fi
}

src_install() {
	platform_src_install

	into /
	dosbin "${OUT}/keygen"
	dosbin "${OUT}/session_manager"

	# Install DBus configuration.
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.SessionManagerInterface.xml

	insinto /etc/dbus-1/system.d
	doins SessionManager.conf

	# Adding init scripts.
	if use systemd; then
		systemd_dounit init/systemd/*
		systemd_enable_service x-started.target
		systemd_enable_service multi-user.target ui.target
		systemd_enable_service ui.target ui.service
		systemd_enable_service ui.service machine-info.service
		systemd_enable_service login-prompt-visible.target send-uptime-metrics.service
		systemd_enable_service login-prompt-visible.target ui-init-late.service
		systemd_enable_service start-user-session.target login.service
		systemd_enable_service system-services.target ui-collect-machine-info.service
	else
		insinto /etc/init
		doins init/upstart/*.conf
	fi
	exeinto /usr/share/cros/init/
	doexe init/scripts/*

	dotmpfiles tmpfiles.d/chromeos-login.conf

	# For user session processes.
	dodir /etc/skel/log

	# For user NSS database
	diropts -m0700
	# Need to dodir each directory in order to get the opts right.
	dodir /etc/skel/.pki
	dodir /etc/skel/.pki/nssdb
	# Yes, the created (empty) DB does work on ARM, x86 and x86_64.
	certutil -N -d "sql:${D}/etc/skel/.pki/nssdb" -f <(echo '') || die

	insinto /etc
	doins chrome_dev.conf

	insinto /usr/share/power_manager
	doins powerd_prefs/suspend_freezer_deps_*

	# Create daemon store directories.
	local daemon_store="/etc/daemon-store/session_manager"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners root:root "${daemon_store}"

	local fuzzers=(
		login_manager_validator_utils_fuzzer
		login_manager_validator_utils_policy_desc_fuzzer
	)

	local fuzzer
	for fuzzer in "${fuzzers[@]}"; do
		# fuzzer_component_id is unknown/unlisted
		platform_fuzzer_install "${S}"/OWNERS "${OUT}/${fuzzer}"
	done
}
