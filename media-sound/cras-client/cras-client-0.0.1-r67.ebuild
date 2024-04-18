# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_WORKON_COMMIT="6a48b356931b0731d6ca0578caf4f94c94e4b6c7"
CROS_WORKON_TREE=("39dfa48e821182088123447e6289d9ad4e37d884" "330e222386b99c058da8e3c184ad59cf50a06fe3" "695522ac55a4decc9caf07a5dcb173695bd89444")
CROS_RUST_SUBDIR="cras/client"
# TODO(b/175640259) Fix tests for ARM.
CROS_RUST_TEST_DIRECT_EXEC_ONLY="yes"

CROS_WORKON_LOCALNAME="adhd"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since cras-sys/Cargo.toml is
# using "provided by ebuild" macro which supported by cros-rust.
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="${CROS_RUST_SUBDIR} cras/include cras/dbus_bindings"

inherit cros-workon cros-rust

DESCRIPTION="All cras client Rust code"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/adhd/+/HEAD/cras/client"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="
	dev-rust/chromeos-dbus-bindings:=
	dev-rust/data_model:=
	dev-rust/libchromeos:=
	dev-rust/third-party-crates-src:=
	dev-libs/openssl:0=
	media-sound/audio_streams:=
	media-sound/cras_rust:=
	sys-apps/dbus:=
	virtual/bindgen:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	!media-sound/cras-sys
	!media-sound/cras_tests
	!media-sound/libcras
	!<media-sound/cras_rust-0.1.2
"

BDEPEND="
	dev-rust/bindgen
	dev-rust/dbus-codegen
	media-libs/alsa-lib:=
"

# When installing this as a binpkg, we have to be able to specify the versions
# of these crates without access to sources (e.g., we can't call
# `cros-rust_get_crate_version` from `pkg_*inst` functions), so hardcode the
# versions.
export_crates=("cras-sys" "libcras")
export_crate_versions=("0.1.0" "0.1.0")

src_unpack() {
	cros-rust_src_unpack

	# Ensure `export_crate_versions` is still consistent.
	if [[ "${#export_crates[@]}" != "${#export_crate_versions[@]}" ]]; then
		die "export_crates and export_crate_versions must have the same number of elements"
	fi

	local crate_ver i
	for i in "${!export_crates[@]}"; do
		crate_ver="$(cros-rust_get_crate_version "${S}/${export_crates[${i}]}")" || die
		if [[ "${crate_ver}" != "${export_crate_versions[${i}]}" ]]; then
			die "Crate ${export_crates[${i}]} version ${crate_ver} doesn't match expected version: ${export_crate_versions[${i}]}"
		fi
	done
}

src_prepare() {
	cros-rust_src_prepare
	cros-rust-patch-cargo-toml "${S}/audio_diagnostics/Cargo.toml"
	cros-rust-patch-cargo-toml "${S}/cras_tests/Cargo.toml"
	cros-rust-patch-cargo-toml "${S}/cras-sys/Cargo.toml"
	cros-rust-patch-cargo-toml "${S}/libcras/Cargo.toml"
}

src_compile() {
	cros-rust_src_compile --workspace
}

src_test() {
	cros-rust_src_test --workspace
}

src_install() {
	local crate i
	for i in "${!export_crates[@]}"; do
		crate="${export_crates[${i}]}"
		(
			cd "${crate}" || die
			cros-rust_publish "${crate}" "${export_crate_versions[${i}]}"
		)
	done

	dobin "$(cros-rust_get_build_dir)/cras_tests"
	dobin "$(cros-rust_get_build_dir)/audio_diagnostics"
}

pkg_preinst() {
	local i
	for i in "${!export_crates[@]}"; do
		cros-rust_pkg_preinst "${export_crates[${i}]}" "${export_crate_versions[${i}]}"
	done
}

pkg_postinst() {
	local i
	for i in "${!export_crates[@]}"; do
		cros-rust_pkg_postinst "${export_crates[${i}]}" "${export_crate_versions[${i}]}"
	done
}

pkg_prerm() {
	local i
	for i in "${!export_crates[@]}"; do
		cros-rust_pkg_prerm "${export_crates[${i}]}" "${export_crate_versions[${i}]}"
	done
}
