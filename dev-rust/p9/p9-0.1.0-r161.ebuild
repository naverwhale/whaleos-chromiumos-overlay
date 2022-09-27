# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="cce4054aa8cc2cc71575ecf787445b64bf9ba82a"
CROS_WORKON_TREE="65dba8a09cb548acd93876a3ed68287e875eba7c"
CROS_RUST_SUBDIR="common/p9"

CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=""  # TODO(b/195126527): limit subtree to common/

inherit cros-fuzzer cros-workon cros-rust

DESCRIPTION="Server implementation of the 9P file system protocol"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/p9/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="fuzzer test"

DEPEND="
	dev-rust/libc:=
	=dev-rust/proc-macro2-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/syn-1*:=
	dev-rust/sys_util:=
	fuzzer? ( dev-rust/cros_fuzz:= )
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	!!<=dev-rust/p9-0.1.0-r14
"

get_crate_version() {
	local crate="$1"
	awk '/^version = / { print $3 }' "$1/Cargo.toml" | head -n1 | tr -d '"'
}

pkg_setup() {
	cros-rust_pkg_setup wire_format_derive
	cros-rust_pkg_setup p9
}

src_compile() {
	(
		cd wire_format_derive || die
		ecargo_build
		use test && ecargo_test --no-run
	)

	ecargo_build
	use test && ecargo_test --no-run

	if use fuzzer; then
		cd fuzz
		ecargo_build_fuzzer
	fi
}

src_test() {
	(
		cd wire_format_derive || die
		cros-rust_src_test
	)

	cros-rust_src_test
}

src_install() {
	pushd wire_format_derive > /dev/null || die
	local version="$(get_crate_version .)"
	cros-rust_publish wire_format_derive "${version}"
	popd > /dev/null || die

	version="$(get_crate_version .)"
	cros-rust_publish p9 "${version}"

	if use fuzzer; then
		local fuzzer_component_id="982362"
		fuzzer_install "${S}/OWNERS" \
			"$(cros-rust_get_build_dir)/p9_tframe_decode_fuzzer" \
			--comp "${fuzzer_component_id}"
	fi
}

pkg_preinst() {
	cros-rust_pkg_preinst wire_format_derive
	cros-rust_pkg_preinst p9
}

pkg_postinst() {
	cros-rust_pkg_postinst wire_format_derive
	cros-rust_pkg_postinst p9
}

pkg_prerm() {
	cros-rust_pkg_prerm wire_format_derive
	cros-rust_pkg_prerm p9
}
