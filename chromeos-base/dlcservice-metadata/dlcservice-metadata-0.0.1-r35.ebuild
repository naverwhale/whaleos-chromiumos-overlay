# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "a6eaa2daa397f15118a3806021521977bc7d1146" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk dlcservice .gn"

PLATFORM_SUBDIR="dlcservice/metadata"

inherit cros-workon platform

DESCRIPTION="DLC metadata library for ChromiumOS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/dlcservice/metadata"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# File libdlcservice-metadata.so moved from dlcservice.
RDEPEND="
	!<=chromeos-base/dlcservice-0.0.1-r1073
"

DEPEND="
	${RDEPEND}
"

platform_pkg_test() {
	platform test_all
}
