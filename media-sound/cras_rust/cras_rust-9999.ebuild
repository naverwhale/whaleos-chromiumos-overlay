# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_SUBDIR="."

CROS_WORKON_LOCALNAME="adhd"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since cras/src/server/rust is
# using the `provided by ebuild` macro from the cros-rust eclass

inherit cros-workon cros-rust

CROS_WORKON_INCREMENTAL_BUILD=1

DESCRIPTION="Rust code which is used within cras"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/adhd/+/HEAD"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="dlc test"

DEPEND="
	dev-libs/openssl:=
	dev-rust/featured:=
	dev-rust/system_api:=
	dev-rust/third-party-crates-src:=
	media-libs/speex:=
	sys-apps/dbus:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="
	${DEPEND}
	!media-sound/audio_processor
	!<media-sound/adhd-0.0.7
"

# When installing this as a binpkg, we have to be able to specify the versions
# of these crates without access to sources (e.g., we can't call
# `cros-rust_get_crate_version` from `pkg_*inst` functions), so hardcode the
# versions.
export_crates=("audio_processor" "cras_dlc" "cras" "cras_features_backend")
export_crate_versions=("0.1.0" "0.1.0" "0.1.1" "0.1.0")
export_crate_paths=("audio_processor" "cras/src/server/rust/cras_dlc" "cras/src/server/rust" "cras/platform/features")

src_unpack() {
	cros-rust_src_unpack

	# Ensure `export_crate_versions` and `export_crate_paths` are still consistent.
	if [[ "${#export_crates[@]}" != "${#export_crate_versions[@]}" ]]; then
		die "export_crates and export_crate_versions must have the same number of elements"
	fi
	if [[ "${#export_crates[@]}" != "${#export_crate_paths[@]}" ]]; then
		die "export_crates and export_crate_paths must have the same number of elements"
	fi

	local crate_ver i
	for i in "${!export_crates[@]}"; do
		crate_ver="$(cros-rust_get_crate_version "${S}/${export_crate_paths[${i}]}")" || die
		if [[ "${crate_ver}" != "${export_crate_versions[${i}]}" ]]; then
			die "Crate ${export_crates[${i}]} version ${crate_ver} doesn't match expected version: ${export_crate_versions[${i}]}"
		fi
	done
}

src_prepare() {
	cros-rust_src_prepare
	cros-rust-patch-cargo-toml "${S}/audio_processor/Cargo.toml"
}


src_compile() {
	local features=(
		$(usex dlc dlc "")
		"chromiumos"
	)
	cros-rust_src_compile --features="${features[*]}" --workspace
}

src_test() {
	local features=(
		$(usex dlc dlc "")
	)
	cros-rust_src_test --features="${features[*]}" --workspace
}

src_install() {
	local crate crate_path i
	for i in "${!export_crates[@]}"; do
		crate="${export_crates[${i}]}"
		crate_path="${export_crate_paths[${i}]}"
		(
			cd "${crate_path}" || die
			cros-rust_publish "${crate}" "${export_crate_versions[${i}]}"
		)
	done

	dolib.a "$(cros-rust_get_build_dir)/libcras_rust.a"

	# Install to /usr/local so they are stripped out of the release image.
	into /usr/local
	dobin "$(cros-rust_get_build_dir)/offline-pipeline"
	dobin "$(cros-rust_get_build_dir)/rock"
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
