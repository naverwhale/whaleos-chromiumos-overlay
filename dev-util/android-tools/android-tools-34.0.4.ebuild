# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Android platform tools (adb, fastboot, and mkbootimg)"
HOMEPAGE="https://github.com/nmeum/android-tools/ https://developer.android.com/"

MY_PV="${PV//_/}"
SRC_URI="https://github.com/nmeum/android-tools/releases/download/${MY_PV}/${PN}-${MY_PV}.tar.xz
	https://dev.gentoo.org/~zmedico/dist/${PN}-31.0.3-no-gtest.patch
"
S="${WORKDIR}/${PN}-${MY_PV}"

# The entire source code is Apache-2.0, except for fastboot which is BSD-2.
LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="-udev"

# dev-libs/libpcre only required for e2fsdroid
DEPEND="
	app-arch/brotli:=
	app-arch/lz4:=
	app-arch/zstd:=
	dev-libs/libpcre2:=
	>=dev-libs/protobuf-3.0.0:=
	sys-libs/zlib:=
	virtual/libusb:1=
"
RDEPEND="${DEPEND}
	udev? ( dev-util/android-udev-rules )
"
BDEPEND="
	dev-lang/go
	dev-lang/perl
"

DOCS=()

src_prepare() {
	# ChromeOS patches.
	eapply "${FILESDIR}/${PN}-34.0.0-homedir.patch"
	eapply "${DISTDIR}/${PN}-31.0.3-no-gtest.patch"

	cd "${S}/vendor/core" || die
	eapply "${S}/patches/core/0011-Remove-the-useless-dependency-on-gtest.patch"

	cd "${S}/vendor/libziparchive" || die
	eapply "${S}/patches/libziparchive/0004-Remove-the-useless-dependency-on-gtest.patch"

	cd "${S}" || die
	rm -r patches || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		# Statically link the bundled boringssl
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_src_configure
}

src_compile() {
	export GOCACHE="${T}/go-build"
	export GOFLAGS="-mod=readonly" # ChromeOS: changed from vendor
	cmake_src_compile
}

src_install() {
	cmake_src_install
	rm "${ED}/usr/bin/mkbootimg" || die
	rm "${ED}/usr/bin/unpack_bootimg" || die
	rm "${ED}/usr/bin/repack_bootimg" || die
	rm "${ED}/usr/bin/mkdtboimg" || die
	rm "${ED}/usr/bin/avbtool" || die

	docinto adb
	dodoc vendor/adb/*.{txt,TXT}
	docinto fastboot
	dodoc vendor/core/fastboot/README.md
}
