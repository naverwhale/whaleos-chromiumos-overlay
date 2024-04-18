# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

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
KEYWORDS="~*"
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
