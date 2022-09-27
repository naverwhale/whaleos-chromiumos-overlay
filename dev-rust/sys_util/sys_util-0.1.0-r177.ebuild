# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="1fd68656a2c3fbbd8a248930d079c733cc93d51f"
CROS_WORKON_TREE="7aa59e9a74d28db65c5214d670dbda110ae5742d"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="sys_util"
CROS_WORKON_SUBDIRS_TO_COPY="sys_util"

inherit cros-workon cros-rust

DESCRIPTION="Small system utility modules for usage by other modules."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/crosvm/+/HEAD/sys_util"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

# ebuilds that install executables, import sys_util, and use the libcap
# functionality need to RDEPEND on libcap
DEPEND="
	=dev-rust/android_log-sys-0.2*:=
	dev-rust/assertions:=
	dev-rust/data_model:=
	>=dev-rust/libc-0.2.93:= <dev-rust/libc-0.3.0
	=dev-rust/proc-macro2-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/remain-0.2*:=
	=dev-rust/serde-1*:=
	=dev-rust/serde_json-1*:=
	=dev-rust/syn-1*:=
	dev-rust/sync:=
	dev-rust/tempfile:=
	>=dev-rust/thiserror-1.0.20:= <dev-rust/thiserror-2.0
	sys-libs/libcap:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	!!<=dev-rust/sys_util-0.1.0-r60
"

src_test() {
	local skip_tests=()

	# These tests directly make a clone(2) syscall, which makes sanitizers very
	# unhappy since they see memory allocated in the child process that is not
	# freed (because it is owned by some other thread created by the test runner
	# in the parent process).
	cros-rust_use_sanitizers && skip_tests+=( --skip "fork::tests" )
	# The memfd_create() system call first appeared in Linux 3.17.  Skip guest
	# memory tests for builders with older kernels.
	local cut_version=$(ver_cut 1-2 "$(uname -r)")
	if ver_test 3.17 -gt "${cut_version}"; then
		skip_tests+=( --skip "guest_memory::tests" )
	fi

	# If syslog isn't available, skip the tests.
	[[ -S /dev/log ]] || skip_tests+=( --skip "syslog::tests" )

	# TODO(crbug.com/1157570) Remove once syslog module works in sandbox.
	CROS_RUST_TEST_DIRECT_EXEC_ONLY="yes"
	cros-rust_get_host_test_executables

	cros-rust_src_test -- --test-threads=1 "${skip_tests[@]}"
}

src_install() {
	(
		cd poll_token_derive || die
		cros-rust_publish poll_token_derive "$(cros-rust_get_crate_version .)"
	)

	cros-rust_src_install
}

pkg_preinst() {
	cros-rust_pkg_preinst poll_token_derive
	cros-rust_pkg_preinst
}

pkg_postinst() {
	cros-rust_pkg_postinst poll_token_derive
	cros-rust_pkg_postinst
}

pkg_prerm() {
	cros-rust_pkg_prerm poll_token_derive
	cros-rust_pkg_prerm
}
