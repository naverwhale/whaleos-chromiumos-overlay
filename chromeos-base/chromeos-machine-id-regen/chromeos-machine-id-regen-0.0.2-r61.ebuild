# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "2efb708856a5fb82873d36ecc04514a7854c105a" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk machine-id-regen metrics .gn"

PLATFORM_SUBDIR="machine-id-regen"

inherit cros-workon platform systemd

DESCRIPTION="Utility to periodically update machine-id"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/machine-id-regen/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="systemd"

DEPEND="
	chromeos-base/metrics:=
	sys-apps/dbus:=
	sys-apps/upstart:=
"

RDEPEND="${DEPEND}"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
	platform_src_install

	# Install init scripts for systemd the ones for upstart are installd via
	# BUILD.gn.
	if use systemd; then
		systemd_dounit init/machine-id-regen-network.service
		systemd_dounit init/machine-id-regen-periodic.service
		systemd_enable_service shill-disconnected.target machine-id-regen-network.service
		systemd_dounit init/machine-id-regen-periodic.timer
		systemd_enable_service system-services.target machine-id-regen-periodic.timer
	fi
}

platform_pkg_test() {
	platform test_all
}
