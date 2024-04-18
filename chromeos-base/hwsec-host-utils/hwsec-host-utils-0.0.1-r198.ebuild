# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "b1448f74c5d75820b7d3a269c75b1409cf747e35" "0d345aa95a2088afd12e25fd820a24ad6fb19c4a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk hwsec-host-utils trunks .gn"

PLATFORM_SUBDIR="hwsec-host-utils"

inherit cros-workon platform

DESCRIPTION="Hwsec-related host-only utilities."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/hwsec-host-utils/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host"
REQUIRED_USE="cros_host"

COMMON_DEPEND="
	chromeos-base/trunks:=
	app-crypt/trousers:=
	dev-cpp/abseil-cpp:=
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

platform_pkg_test() {
	platform test_all
}
