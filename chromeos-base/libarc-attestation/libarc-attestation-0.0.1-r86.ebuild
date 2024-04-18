# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "8c1e2be23c220f14c478b27ca09008033706e4e7" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libarc-attestation .gn"

PLATFORM_SUBDIR="libarc-attestation"

inherit cros-workon platform

DESCRIPTION="Utility for ARC Keymintd to perform Android Attestation and Remote Key Provisioning"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libarc-attestation/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	chromeos-base/libhwsec:=[test?]
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/system_api:=
	"

DEPEND="
	${RDEPEND}
	"

platform_pkg_test() {
	platform test_all
}
