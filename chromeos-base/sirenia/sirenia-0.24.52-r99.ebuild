# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="e1280814061d6bc30e6ccd8c13fdc68ee2dc4c0d"
CROS_WORKON_TREE="b4f25a3f495992fa990ccf351f28dc6742176ba8"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="sirenia"

inherit cros-workon cros-rust user

DESCRIPTION="The runtime environment and middleware for ManaTEE."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/sirenia/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host manatee"

DEPEND="
	chromeos-base/libsirenia:=
	dev-libs/openssl:0=
	=dev-rust/anyhow-1*:=
	=dev-rust/base64-0.13*:=
	dev-rust/chromeos-dbus-bindings:=
	=dev-rust/dbus-0.9*:=
	=dev-rust/dbus-crossroads-0.4*:=
	>=dev-rust/flexbuffers-0.1.1 <dev-rust/flexbuffers-0.2.0_alpha:=
	=dev-rust/getopts-0.2*:=
	>=dev-rust/libc-0.2.94 <dev-rust/libc-0.3.0_alpha:=
	dev-rust/libchromeos:=
	=dev-rust/log-0.4*:=
	=dev-rust/openssl-0.10*:=
	>=dev-rust/serde-1.0.114 <dev-rust/serde-2:=
	=dev-rust/serde_derive-1*:=
	>=dev-rust/serde_json-1.0.64 <dev-rust/serde_json-2.0.0_alpha:=
	=dev-rust/stderrlog-0.5*:=
	dev-rust/sys_util:=
	>=dev-rust/thiserror-1.0.20 <dev-rust/thiserror-2.0.0_alpha:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	chromeos-base/cronista
	chromeos-base/manatee-runtime
	dev-rust/manatee-client
	sys-apps/dbus
"
BDEPEND="chromeos-base/sirenia-tools"

src_install() {
	local build_dir="$(cros-rust_get_build_dir)"
	dobin "${build_dir}/dugong"

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.ManaTEE.conf

	# Needed for initramfs, but not for the root-fs.
	if use cros_host ; then
		# /build is not allowed when installing to the host.
		exeinto "/bin"
	else
		exeinto "/build/initramfs"
	fi

	if use manatee ;  then
		insinto /etc/init
		doins upstart/dugong.conf
		doexe "${build_dir}/trichechus"
	else
		dobin "${build_dir}/trichechus"
	fi
}

pkg_setup() {
	enewuser dugong
	enewgroup dugong
	cros-rust_pkg_setup
}
