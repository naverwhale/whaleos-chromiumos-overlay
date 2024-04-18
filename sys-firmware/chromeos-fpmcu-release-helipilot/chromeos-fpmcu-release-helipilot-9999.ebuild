# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# Increment the "eclass bug workaround count" below when you change
# "cros-ec-release.eclass" to work around https://issuetracker.google.com/201299127.
#
# eclass bug workaround count: 8

EAPI=7

FIRMWARE_EC_BOARD="helipilot"
FIRMWARE_EC_RELEASE_REPLACE_RO="yes"

# Note that auto-uprev is disabled! Make sure to check all requisite repos,
# commits, etc each time this gets modified!
CROS_WORKON_MANUAL_UPREV=1

CROS_WORKON_PROJECT=(
	"chromiumos/platform/ec"
	"chromiumos/third_party/cryptoc"
	"external/gob/boringssl/boringssl"
	"external/github.com/google/googletest"
)

CROS_WORKON_LOCALNAME=(
	"../platform/ec"
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
	"firmware-fpmcu-helipilot-release"
	"master" # TODO(b/305093451) this should probably be main
	" " # default value is space. See "cros-workon.eclass" for details.
	" " # default value is space. See "cros-workon.eclass" for details.
)

inherit cros-workon cros-ec-release cros-sanitizers

HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/ec/+/HEAD/README.md"
LICENSE="BSD-Google"
KEYWORDS="~*"

src_configure() {
	sanitizers-setup-env
	default
}
