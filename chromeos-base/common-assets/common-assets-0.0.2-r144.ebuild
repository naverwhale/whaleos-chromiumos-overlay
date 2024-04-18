# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="d8590410975b8aee2e9666331691e24d5762c6b0"
CROS_WORKON_TREE="d48de3935910b5017495a82c78521b49bf54690d"
CROS_WORKON_PROJECT="chromiumos/platform/assets"
CROS_WORKON_LOCALNAME="platform/assets"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon

DESCRIPTION="Common Chromium OS assets (images, sounds, etc.)"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/assets"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	+fonts
"

# display_boot_message calls the pango-view program.
RDEPEND="
	fonts? ( chromeos-base/chromeos-fonts )
	x11-libs/pango"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins -r images/*

	insinto /usr/share/chromeos-assets/images_100_percent
	doins -r images_100_percent/*

	insinto /usr/share/chromeos-assets/images_200_percent
	doins -r images_200_percent/*

	insinto /usr/share/chromeos-assets/text
	doins -r text/boot_messages
	dosbin text/display_boot_message

	# These files aren't used at runtime.
	find "${D}" -name '*.grd' -delete
}
