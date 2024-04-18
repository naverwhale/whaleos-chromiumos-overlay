# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("db749a759fbf2f6525efd1913a59051ea7472796" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "351fb08db6b0e98a2c6de16681f05c1876359158" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "fea40a8b93606b2fc977192b0be1108448fbcfe4" "0d345aa95a2088afd12e25fd820a24ad6fb19c4a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="attestation common-mk hwsec-test-utils libhwsec libhwsec-foundation tpm_manager trunks .gn"

PLATFORM_SUBDIR="hwsec-test-utils"

inherit cros-workon platform

DESCRIPTION="Hwsec-related test-only features. This package resides in test images only."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/hwsec-test-utils/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test tpm tpm_dynamic tpm2"
REQUIRED_USE="
	tpm_dynamic? ( tpm tpm2 )
	!tpm_dynamic? ( ?? ( tpm tpm2 ) )
"

RDEPEND="
	tpm? (
		app-crypt/trousers:=
	)
	chromeos-base/attestation:=
	chromeos-base/libhwsec:=
	chromeos-base/libhwsec-foundation:=
	chromeos-base/system_api:=
	chromeos-base/tpm_manager-client:=
	tpm2? (
		chromeos-base/trunks:=
	)
	dev-libs/openssl:=
	dev-libs/protobuf:=
"

DEPEND="${RDEPEND}
	tpm2? (
		chromeos-base/trunks:=[test?]
	)
"

platform_pkg_test() {
	platform test_all
}
