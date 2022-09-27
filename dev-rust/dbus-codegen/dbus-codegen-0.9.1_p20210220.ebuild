# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Binary crate to generate Rust code from XML introspection data'
HOMEPAGE='https://crates.io/crates/dbus-codegen'
GIT_REV="006994e300f1211120fb707028c04acf76ac4ebe"
SRC_URI="https://github.com/diwic/dbus-rs/archive/${GIT_REV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0/${PVR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/clap-2*:=
	=dev-rust/dbus-0.9*:=
	=dev-rust/dbus-tree-0.9*:=
	=dev-rust/dbus-crossroads-0.4*:=
	>=dev-rust/xml-rs-0.8.3:= <dev-rust/xml-rs-0.9.0_alpha
"
RDEPEND="${DEPEND}"

src_unpack() {
	cros-rust_src_unpack

	# For this ebuild we only care about the dbus-codegen subcrate.
	mv "${WORKDIR}/dbus-rs-${GIT_REV}/dbus-codegen" "${WORKDIR}/${P}"
}

src_prepare() {
	# Patch out the path-wise inclusion of dependencies and specify a version for
	# dbus-crossroads.
	sed -i \
		-e 's/path = "\.\.\/dbus-crossroads"/version = "0.4.0"/g' \
		-e 's/path = "[^"]\+", //g' "${S}/Cargo.toml"

	cros-rust_src_prepare
}

src_compile() {
	ecargo_build
}

src_install() {
	dobin "$(cros-rust_get_build_dir)/dbus-codegen-rust"
}
