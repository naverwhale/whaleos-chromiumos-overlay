# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7
CROS_WORKON_PROJECT="chromiumos/platform/spdm"
CROS_WORKON_LOCALNAME="platform/spdm"

inherit cros-workon cros-rust

DESCRIPTION="SPDM (Secure Protocol and Data Model) protocol implemented for secured messaging between userland and Google Security Chip."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/spdm/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
# Unstable tests might be broken by toolchain updates. If this package blocks
# toolchain updates, please remove the '+' to make unstable tests not built by
# default, and file a bug at componentid:1188704.
IUSE="+spdm_unstable_tests"

RDEPEND="
	dev-rust/third-party-crates-src:=
"

DEPEND="${RDEPEND}"

src_unpack() {
	# Unpack both the project and dependency source code
	cros-workon_src_unpack
	cros-rust_src_unpack
}

src_prepare() {
	# The only Cargo.toml file in the package that needs manipulation is
	# spdm-core's.
	local cargo_toml_path="${S}/spdm-core/Cargo.toml"
	use spdm_unstable_tests || sed -i '/# ignored unless use.spdm_unstable_tests by ebuild/d' "${cargo_toml_path}" || die

	# Not using cros-rust_src_prepare because it wrongly assumes Cargo.toml is
	# in the root of ${S} and we don't need its manipulations anyway.
	default
}

src_configure() {
	# The unstable tests need the extra allow features.
	if use spdm_unstable_tests; then
		# shellcheck disable=SC2034
		CROS_RUST_EXTRA_ALLOWED_FEATURES=("fn_traits" "tuple_trait" "unboxed_closures")
	fi
	cros-rust_src_configure
}

src_install() {
	local build_dir="$(cros-rust_get_build_dir)"
	dolib.a "${build_dir}"/libspdm.a

	insinto /usr/include/spdm
	doins spdm.h
}

src_test() {
	local test_args=("--workspace")
	# Tests using mock (hence the mocktopus package) require unstable features,
	# only run them wen the use flag is specified.
	if use spdm_unstable_tests; then
		test_args+=("--features=mock")
	fi

	cros-rust_src_test "${test_args[@]}"
}
