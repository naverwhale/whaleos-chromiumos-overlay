# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("ae07277fe7394cbb60e746d21d17f2f0a1ac163b" "bd1416be85fc5c317a2e6171be066ed98841e643")
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "7266a528f4e14ef315147b65bc5f48bd7127e5b9")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/cbor"
)

CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/cbor"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	# This needs to be platform2/cbor instead of platform/cbor because we are
	# using the platform2 build system.
	"${S}/platform2/cbor"
)

CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="cbor"

inherit cros-workon platform

DESCRIPTION="Concise Binary Object Representation (CBOR) library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/cbor"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	platform_src_install

	dolib.so "${OUT}"/lib/libcbor.so
	insinto /usr/include/chromeos/cbor/
	doins ./*.h
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/obj/cbor/cbor.pc

	local fuzzer_component_id="923964"
	platform_fuzzer_install "${S}/OWNERS" "${OUT}"/reader_fuzzer \
		--comp "${fuzzer_component_id}"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cbor_unittests"
}
