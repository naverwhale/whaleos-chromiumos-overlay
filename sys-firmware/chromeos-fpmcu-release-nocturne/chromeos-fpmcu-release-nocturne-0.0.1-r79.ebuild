# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# Increment the "eclass bug workaround count" below when you change
# "cros-ec-release.eclass" to work around https://issuetracker.google.com/201299127.
#
# eclass bug workaround count: 8

EAPI=7

CROS_WORKON_COMMIT=("23c9539579a49d0558648812a51d4c0d4c2199bc" "0dd679081b9c8bfa2583d74e3a17a413709ea362" "e0d601a57fde7d67a1c771e7d87468faf1f8fe55" "8fa9461cc28e053d66f17132808d287ae51575e2")
CROS_WORKON_TREE=("022e61b69a584abebeab34929a0f892f1df0f44b" "d99abee3f825248f344c0638d5f9fcdce114b744" "307ef78893e2eb0851e7d09bb2fd535748bbccf7" "db0717a7f90d588243994b56d4bb206be31cc9a2")
FIRMWARE_EC_BOARD="nocturne_fp"
FIRMWARE_EC_RELEASE_REPLACE_RO="yes"

CROS_WORKON_PROJECT=(
	"chromiumos/platform/ec"
	"chromiumos/third_party/cryptoc"
	"external/gob/boringssl/boringssl"
	"external/github.com/google/googletest"
)

CROS_WORKON_LOCALNAME=(
	"../platform/release-firmware/fpmcu-nocturne"
	"cryptoc"
	"boringssl"
	"googletest"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform/ec"
	"${S}/third_party/cryptoc"
	"${S}/third_party/boringssl"
	"${S}/third_party/googletest"
)

CROS_WORKON_EGIT_BRANCH=(
	"firmware-fpmcu-dartmonkey-release"
	"master"
	" " # default value is space. See "cros-workon.eclass" for details.
	" " # default value is space. See "cros-workon.eclass" for details.
)

inherit cros-workon cros-ec-release

HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/ec/+/master/README.md"
LICENSE="BSD-Google"
KEYWORDS="*"
