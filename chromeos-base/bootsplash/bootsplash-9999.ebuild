# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk bootsplash libec .gn"

PLATFORM_SUBDIR="bootsplash"

inherit cros-workon platform user

DESCRIPTION="Frecon-based boot splash service"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/bootsplash"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"

DEPEND="
	chromeos-base/bootstat:=
	chromeos-base/session_manager-client:=
	chromeos-base/system_api:=
	dev-libs/re2:=
"

RDEPEND="
	${DEPEND}
	sys-apps/frecon
"

pkg_preinst() {
	enewuser "bootsplash"
	enewgroup "bootsplash"
}

src_install() {
	platform_src_install

	dobin "${OUT}/bootsplash"
}

platform_pkg_test() {
	platform test_all
}
