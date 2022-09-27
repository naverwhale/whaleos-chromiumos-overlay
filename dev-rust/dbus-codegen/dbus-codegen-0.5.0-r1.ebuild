# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Binary crate to generate Rust code from XML introspection data."
HOMEPAGE="https://github.com/diwic/dbus-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0/${PVR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/clap-2.20.0:= <dev-rust/clap-3
	>=dev-rust/dbus-0.8.0:= <dev-rust/dbus-0.9.0
	>=dev-rust/xml-rs-0.3.0:= <dev-rust/xml-rs-0.4.0
"

# Block previous versions because 0.3.0-r0 had the incorrect slot.
RDEPEND="
	!<dev-rust/dbus-codegen-0.5.0
	sys-apps/dbus
"

src_compile() {
	ecargo_build
}

src_install() {
	dobin "$(cros-rust_get_build_dir)/dbus-codegen-rust"
}
