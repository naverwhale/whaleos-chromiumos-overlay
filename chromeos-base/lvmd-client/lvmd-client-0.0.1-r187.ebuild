# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "d44eaa9d4aeef1b3da8949ca2e90657848310664" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk lvmd .gn"

# This is where BUILD.gn is located.
# For platform2 projects, this indicates that GN should be used to build this
# package.
PLATFORM_SUBDIR="lvmd/client"

inherit cros-workon platform

DESCRIPTION="Lvmd DBus client library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/lvmd/"

LICENSE="BSD-Google"
KEYWORDS="*"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

# Workaround to rebuild this package on the chromeos-dbus-bindings update.
# Please find the comment in chromeos-dbus-bindings for its background.
DEPEND="
	chromeos-base/chromeos-dbus-bindings:=
"

RDEPEND=""

src_install() {
	platform_src_install

	# Install DBus client library.
	platform_install_dbus_client_lib "lvmd"
}
