# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/hardware/nxp/uwb")
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/hardware/nxp/uwb")
CROS_WORKON_DESTDIR=("${S}" "${S}/uwbd/nxp_hal/")
CROS_WORKON_SUBTREE=("uwbd" "")

CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon cros-rust udev user

DESCRIPTION="The UWB D-Bus daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/uwbd"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"
IUSE="uwbd_client"

BDEPEND="dev-libs/protobuf"
DEPEND="
	cros_host? ( dev-libs/protobuf:= )
	dev-rust/third-party-crates-src:=
	dev-rust/chromeos-dbus-bindings:=
	dev-rust/libchromeos:=
	net-wireless/uwb_core:=
"
RDEPEND="${DEPEND}"

pkg_preinst() {
	# Create user and group for uwbd
	enewuser "uwbd"
	enewgroup "uwbd"
}

src_install() {
	# Install the uwbd binary.
	dobin "$(cros-rust_get_build_dir)/uwbd"
	if use uwbd_client; then
		dobin "$(cros-rust_get_build_dir)/uwbd_client"
	fi

	# Install udev rule
	udev_dorules "${S}/udev/99-uwb.rules"

	# Install the DBus config.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.uwbd.conf

	# Install the upstart config.
	insinto /etc/init
	doins upstart/uwbd.conf

	# Install HAL config.
	insinto /etc/uwb
	doins "${S}/nxp_hal/halimpl/config/SR1XX/libuwb-nxp-type2gc-es1.conf"

	# Install the seccomp filter.
	insinto /usr/share/policy
	doins upstart/seccomp/uwbd-seccomp.policy
}
