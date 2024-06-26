# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="7cb062fc0a74ce34711f2b0194396975866e1872"
CROS_WORKON_TREE="47ba70287eeebe72ee1bc18eb083607b8baf3b9d"
CROS_RUST_SUBDIR="cros_alsa/cros_alsa_derive"

CROS_WORKON_LOCALNAME="adhd"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
CROS_WORKON_INCREMENTAL_BUILD=1
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since cros_alsa/Cargo.toml
# is using "provided by ebuild" macro which supported by cros-rust
CROS_WORKON_SUBTREE="cros_alsa"

inherit cros-workon cros-rust

DESCRIPTION="Derive macros of cros_alsa"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/adhd/+/HEAD/cros_alsa"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="
	dev-rust/third-party-crates-src:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"
