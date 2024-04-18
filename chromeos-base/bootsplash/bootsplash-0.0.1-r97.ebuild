# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "aec3facd31dd9d39f0c4661d9dc238beaf19c879" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
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
KEYWORDS="*"

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
