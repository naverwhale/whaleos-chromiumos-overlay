# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="99317a4a4718f1213eaf335b1e6d3b35a608ba3a"
CROS_WORKON_TREE="b2e8202776d56b24ffeaa31f05a45ffeed7c932b"
CROS_RUST_SUBDIR="sof_sys"

CROS_WORKON_LOCALNAME="adhd"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since cras-sys/Cargo.toml is
# using "provided by ebuild" macro which supported by cros-rust.
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="${CROS_RUST_SUBDIR}"

inherit cros-workon cros-rust

DESCRIPTION="Crate for SOF C-structures generated by bindgen"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/adhd/+/HEAD/sof_sys"

SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="dev-rust/third-party-crates-src:="
RDEPEND="${DEPEND}"
