# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "7f3b3b01a5e0579ccc6272030ea26e45c3bc3140" "04af2f1005707115b755acd5276795815a335d6b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libcrossystem libsegmentation .gn"

PLATFORM_SUBDIR="libsegmentation"

inherit cros-workon platform

DESCRIPTION="Library to get Chromium OS system properties"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libsegmentation"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="feature_management test"

COMMON_DEPEND="
	chromeos-base/libcrossystem:=[test?]
	dev-libs/protobuf:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/feature-management-data:=
"

BDEPEND="
	dev-libs/protobuf
"

platform_pkg_test() {
	platform test_all
}
