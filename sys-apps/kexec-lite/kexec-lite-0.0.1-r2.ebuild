# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="32d0da80b23dbef47755043ae61026e7fcd47b7f"
CROS_WORKON_TREE="4c5887ae18a7e14601a7fcb3dc857156fa61fbb1"
CROS_RUST_SUBDIR="kdump/kexec-lite"

CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="${CROS_RUST_SUBDIR}"

inherit cros-workon cros-rust

DESCRIPTION="Simple implementation of kexec-tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/kdump/kexec-lite"
LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="dev-rust/third-party-crates-src:="

src_install() {
	dosbin "$(cros-rust_get_build_dir)"/kexec-lite
}
