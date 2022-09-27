# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This lives separately from the main minijail ebuild since we don't have Rust
# available in the SDK builder.
# TODO: Consider moving back into main ebuild once crbug.com/1046088 is
# resolved.

EAPI=7

CROS_WORKON_COMMIT="74296b3ba8ca5b2e464f741e309d937be0e444e7"
CROS_WORKON_TREE="9e34181382f35f4cedb5a0dfd86afd39212d42f8"
inherit cros-constants

CROS_RUST_SUBDIR="rust/minijail"

CROS_WORKON_MANUAL_UPREV=1
CROS_WORKON_LOCALNAME="../aosp/external/minijail"
CROS_WORKON_PROJECT="platform/external/minijail"
CROS_WORKON_EGIT_BRANCH="master"
CROS_WORKON_REPO="${CROS_GIT_AOSP_URL}"
CROS_WORKON_SUBTREE="${CROS_RUST_SUBDIR}"

inherit cros-workon cros-rust

DESCRIPTION="rust bindings for minijail"
HOMEPAGE="https://android.googlesource.com/platform/external/minijail"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="asan test"

DEPEND="
	>=dev-rust/libc-0.2.44:= <dev-rust/libc-0.3.0
	>=dev-rust/minijail-sys-0.0.13:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"

src_test() {
	local args=( -- --test-threads=1 )
	if ! use amd64; then
		# TODO(crbug.com/1201377) enable all tests on ARM when supported.
		args=( --lib "${args[@]}" --skip 'seccomp_no_new_privs' )
	fi
	cros-rust_src_test "${args[@]}"
}
