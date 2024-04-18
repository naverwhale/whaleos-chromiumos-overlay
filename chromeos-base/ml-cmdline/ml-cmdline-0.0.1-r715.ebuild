# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "75f23f887e8c461c47ba7a054257780b41216a35" "725701adb1b6a3ba6dcf4d54de479337b517e5d1" "cceb75d9e5555d3cccb273c52847819feabc9c65" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk ml ml_benchmark ml_core .gn"

PLATFORM_SUBDIR="ml/cmdline"

inherit cros-workon platform

DESCRIPTION="Command line interface to machine learning service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/main/ml"

LICENSE="BSD-Google"
KEYWORDS="*"
SLOT="0/0"
IUSE="internal"

RDEPEND="
	chromeos-base/chrome-icu:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/minijail:=
	chromeos-base/ml:=
	chromeos-base/system_api:=
	dev-libs/ml-core:=
	dev-libs/protobuf:=
	sci-libs/tensorflow:=
	sys-libs/zlib:=
"

DEPEND="
	${RDEPEND}
	dev-libs/libutf:=
	dev-libs/marisa-aosp:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	dev-libs/protobuf
"

platform_pkg_test() {
	platform test_all
}
