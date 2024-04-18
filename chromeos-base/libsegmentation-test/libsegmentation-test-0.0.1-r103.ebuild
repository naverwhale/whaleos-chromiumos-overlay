# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "04af2f1005707115b755acd5276795815a335d6b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libsegmentation .gn"

PLATFORM_SUBDIR="libsegmentation/tools"

inherit cros-workon platform

DESCRIPTION="Test for Library to get ChromiumOS system properties"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libsegmentation"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="feature_management test"

RDEPEND="
	chromeos-base/libsegmentation:=[test?]
"

DEPEND="${RDEPEND}
	chromeos-base/feature-management-data:=
"

BDEPEND="
	dev-libs/protobuf
"
