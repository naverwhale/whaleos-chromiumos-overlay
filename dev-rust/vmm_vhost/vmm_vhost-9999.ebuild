# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_LOCALNAME="rust-vmm/vhost"
CROS_WORKON_PROJECT="chromiumos/third_party/rust-vmm/vhost"
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon cros-rust

# Clear CROS_RUST_SUBDIR because the entire repository is a Rust project.
CROS_RUST_SUBDIR=""

DESCRIPTION="A crate to support vhost backend drivers for virtio devices."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/rust-vmm/vhost/"

LICENSE="Apache-2.0 BSD"
KEYWORDS="~*"

DEPEND="
	>=dev-rust/bitflags-1.0.1:=
	>=dev-rust/libc-0.2.39:=
	dev-rust/sys_util:=
	dev-rust/tempfile:=
	=dev-rust/vm-memory-0.2*:=
"

src_compile() {
	# Make sure the build works with default features.
	ecargo_build
	# Also check that the build works with all features.
	ecargo_build --all-features
	use test && cros-rust_src_test --no-run --all-features
}

src_test() {
	cros-rust_src_test --all-features
}
