# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_PROJECT=("chromiumos/platform/crdyboot" "chromiumos/platform/vboot_reference")
CROS_WORKON_LOCALNAME=("../platform/crdyboot" "../platform/vboot_reference")
CROS_WORKON_DESTDIR=("${S}" "${S}/third_party/vboot_reference")
SRC_URI="test? ( gs://chromeos-localmirror/distfiles/crdyboot_test_data_2d09372b.tar.xz )"
inherit cros-workon cros-rust

DESCRIPTION="Experimental UEFI bootloader for ChromeOS Flex"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

DEPEND="
	dev-libs/nss:=
	dev-rust/third-party-crates-src:=
"
RDEPEND="${DEPEND}"

# Clear the subdir so that we stay in the root of the repo.
CROS_RUST_SUBDIR=""

UEFI_TARGET_I686="i686-unknown-uefi"
UEFI_TARGET_X64_64="x86_64-unknown-uefi"
UEFI_TARGETS=(
	"${UEFI_TARGET_I686}"
	"${UEFI_TARGET_X64_64}"
)

src_prepare() {
	# Drop some packages that are not needed.
	sed -i 's/, "enroller"//' "${S}/Cargo.toml" || die
	sed -i 's/, "xtask"//' "${S}/Cargo.toml" || die

	# Drop dev-dependencies (CROS_RUST_REMOVE_DEV_DEPS doesn't work
	# for packages in a workspace).
	sed -i 's/^regex.*$//' "${S}/vboot/Cargo.toml" || die
	sed -i 's/^simple_logger.*$//' "${S}/vboot/Cargo.toml" || die

	default
}

src_configure() {
	# Remove flags that come from BOARD_RUSTFLAGS and are
	# incompatible with the uefi targets.
	unset CROS_BASE_RUSTFLAGS

	cros-rust_src_configure

	# ECARGO_HOME is defined in cros-rust.eclass
	# shellcheck disable=SC2154
	local ecargo_config="${ECARGO_HOME}/config"

	# Enable the c_variadic feature, used for logging from vboot.
	sed -i 's/-Zallow-features=/&c_variadic,/' "${ecargo_config}" || die

	# Set the appropriate linker for UEFI targets.
	cat <<- EOF >> "${ecargo_config}"
	[target.i686-unknown-uefi]
	linker = "lld-link"

	[target.x86_64-unknown-uefi]
	linker = "lld-link"
	EOF
}

src_compile() {
	# Skip this phase when code coverage is enabled. The UEFI
	# targets are no-std, so they are not trivially compatible with
	# `-Cinstrument-coverage`. Since the actual code coverage is
	# provided by the test phase (which uses a non-UEFI target),
	# skipping compilation here does not affect code coverage.
	if use rust-coverage; then
		return 0
	fi

	# We need to pass in a `--target` to the C compiler, but the
	# compiler-wrapper for the board's CC appends the board target
	# at the end, overriding that setting. Use
	# `x86_64-pc-linux-gnu-clang` instead, as the host wrapper
	# happens to not suffix a target. See
	# `compiler_wrapper/clang_flags.go` at the end of
	# `processClangFlags`.
	export CC="x86_64-pc-linux-gnu-clang"

	for uefi_target in "${UEFI_TARGETS[@]}"; do
		ecargo build \
			--offline \
			--release \
			--target="${uefi_target}" \
			--package crdyboot
	done
}

# Get the standard suffix for a UEFI boot executable.
uefi_arch_suffix() {
	local uefi_target="$1"
	if [[ "${uefi_target}" == "${UEFI_TARGET_I686}" ]]; then
		echo "ia32.efi"
	elif [[ "${uefi_target}" == "${UEFI_TARGET_X64_64}" ]]; then
		echo "x64.efi"
	else
		die "unknown arch: ${uefi_target}"
	fi
}

src_install() {
	# Skip this phase when code coverage is enabled. Since the
	# compile phase was skipped, there's nothing to install.
	if use rust-coverage; then
		return 0
	fi

	insinto /boot/efi/boot
	for uefi_target in "${UEFI_TARGETS[@]}"; do
		# CARGO_TARGET_DIR is defined in an eclass
		# shellcheck disable=SC2154
		newins "${CARGO_TARGET_DIR}/${uefi_target}/release/crdyboot.efi" \
			"crdyboot$(uefi_arch_suffix "${uefi_target}")"
	done
}
