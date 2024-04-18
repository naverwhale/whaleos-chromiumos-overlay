# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="flexor"

inherit cros-workon cros-rust

DESCRIPTION="Contains the main logic for the Flexor experimental Flex installer"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/flexor/"

LICENSE="BSD-Google"
KEYWORDS="~*"

DEPEND="
	dev-rust/third-party-crates-src:=
	dev-rust/libchromeos:=
"

RDEPEND=""

src_install() {
	into "/build/initramfs"
	dosbin "$(cros-rust_get_build_dir)/flexor"
}
