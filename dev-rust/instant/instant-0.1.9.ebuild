# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

# See below.
# CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="A partial replacement for std::time::Instant that works on WASM too."
HOMEPAGE="https://github.com/sebcrozet/instant"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cfg-if-1.0*:=
"

RDEPEND="${DEPEND}"

drop_asmjs_and_wasm32_targets() {
	# Adapted from cros-rust_src_prepare() from cros-rust.eclass.
	# instant's Cargo.toml has a
	#
	# [target."cfg(not(any(feature = \"stdweb\", feature = \"wasm-bindgen\")))".dependencies.time]
	#
	# section that CROS_RUST_REMOVE_TARGET_CFG nukes.  We can
	# instead just remove all asmjs and wasm32 target sections.

	awk \
	'{
		# Stop skipping for a new section header, but check for another match.
		if ($0 ~ /^\[/) {
			skip = 0
		}

		if ($0 ~ /^\[target[.](asmjs|wasm32)/) {
			skip = 1
			next
		}

		# Additionally, drop wasm-bindgen feature
		if ($0 ~ /^\wasm-bindgen/) {
			next
		}

		if (skip == 0) {
			print
		}
	}' "${S}/Cargo.toml" > "${S}/Cargo.toml.stripped" || die

	# Patch line(s) referencing removed features.
	sed -i -e 's/target[.]"cfg(not(any(feature = \\"stdweb\\", feature = \\"wasm-bindgen\\")))"[.]//' \
		"${S}/Cargo.toml.stripped" || die

	mv "${S}/Cargo.toml.stripped" "${S}/Cargo.toml"|| die
}

src_prepare() {
	drop_asmjs_and_wasm32_targets
	cros-rust_src_prepare
}
