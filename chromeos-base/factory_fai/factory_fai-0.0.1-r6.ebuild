# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="9faaf07e39baf005c3bda10ad679eafd68a25f91"
CROS_WORKON_TREE="057b435c3966439abf35b1074c25d880b446934d"
CROS_WORKON_PROJECT="chromiumos/platform/factory_installer"
CROS_WORKON_LOCALNAME="platform/factory_installer"
CROS_RUST_CRATE_NAME="factory_fai"
CROS_RUST_SUBDIR="rust"
CROS_RUST_TEST_DIRECT_EXEC_ONLY="yes"

inherit cros-workon cros-rust

DESCRIPTION="ChromeOS Factory First Article Inspection binary"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/factory_installer/"
SRC_URI=""
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

DEPEND="dev-rust/third-party-crates-src:="
RDEPEND="!<chromeos-base/factory_installer-0.0.2"

src_test() {
	cros-rust_src_test --no-default-features --features="factory-fai" \
		--lib
}

src_compile() {
	cros-rust_src_compile --no-default-features --features="factory-fai" \
		--bin="factory_fai"
}

src_install() {
	dosbin "$(cros-rust_get_build_dir)/factory_fai"
}
