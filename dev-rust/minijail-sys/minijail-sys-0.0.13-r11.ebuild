# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This lives separately from the main minijail ebuild since we don't have Rust
# available in the SDK builder.
# TODO: Consider moving back into main ebuild once crbug.com/1046088 is
# resolved.

EAPI=7

CROS_WORKON_COMMIT="25d0f2ba70ba09959e4e41f6df146aedcaff4e4c"
CROS_WORKON_TREE="9827997d82db7f7e49902f5a62123aa5ab08c3be"
inherit cros-constants

CROS_RUST_SUBDIR="rust/minijail-sys"

CROS_WORKON_MANUAL_UPREV=1
CROS_WORKON_LOCALNAME="../aosp/external/minijail"
CROS_WORKON_PROJECT="platform/external/minijail"
CROS_WORKON_EGIT_BRANCH="master"
CROS_WORKON_REPO="${CROS_GIT_AOSP_URL}"

inherit cros-workon cros-rust

DESCRIPTION="rust bindings for minijail"
HOMEPAGE="https://android.googlesource.com/platform/external/minijail"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

# ebuilds that install executables and depend on minijail-sys need to RDEPEND on
# chromeos-base/minijail and sys-libs/libcap
DEPEND="
	chromeos-base/minijail:=
	>=dev-rust/libc-0.2.44:= <dev-rust/libc-0.3.0
	>=dev-rust/pkg-config-0.3.0:= <dev-rust/pkg-config-0.4.0
	=dev-rust/which-4*:=
	sys-libs/libcap:=
	virtual/bindgen:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"

src_prepare() {
	cros-rust_src_prepare
	# Do not skip regeneration of libminijail.rs.
	export CROS_RUST=0
}
