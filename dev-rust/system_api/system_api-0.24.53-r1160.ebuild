# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="28855525b6c452b8822c99272354f0aece775a5d"
CROS_WORKON_TREE=("ce84e9b1511f8a8a2389efe0a3a5c45b49fb817d" "a0d8550678a1ed2a4ab62782049032a024bf40df" "440408c10fda45485a589ddde83a1601a1c13a1c" "5fc98c479581f2e74f8be63b2063c6e9a261aff4" "21c202c25c8de36a0b08a8b15145db139db51427" "10c6cb234bb010127351e612223155245eae5b70" "8eb751ef0635c3be5ca4765523c8bba614230ccc" "63d3d2b8ce71b0a7966b3d9530e9b12633b744b0" "3a7df68f70c7d697449fd6a965342139eb4dce18" "89b258d4a30905f921b5d553f050a93b168e1a80" "eafa461eb8f602908d40dc48e9c1be360645aa35" "02843c7b1366362e798d2aff718474392f072f92")
CROS_RUST_SUBDIR="system_api"

CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE="${CROS_RUST_SUBDIR} authpolicy/dbus_bindings cryptohome/dbus_bindings debugd/dbus_bindings dlcservice/dbus_adaptors login_manager/dbus_bindings shill/dbus_bindings spaced/dbus_bindings power_manager/dbus_bindings printscanmgr/dbus_bindings vm_tools/dbus_bindings vtpm"

inherit cros-workon cros-rust

DESCRIPTION="Chrome OS system API D-Bus bindings for Rust."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/system_api/"

LICENSE="BSD-Google"
SLOT="0/${PVR}"
KEYWORDS="*"

DEPEND="
	cros_host? ( dev-libs/protobuf:= )
	dev-rust/third-party-crates-src:=
	dev-rust/chromeos-dbus-bindings:=
	sys-apps/dbus:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}
	!chromeos-base/system_api-rust
"

BDEPEND="
	dev-libs/protobuf
	dev-rust/chromeos-dbus-bindings
"

src_install() {
	# We don't want the build.rs to get packaged with the crate. Otherwise
	# we will try and regenerate the bindings.
	rm build.rs || die "Cannot remove build.rs"

	cros-rust_src_install
}
