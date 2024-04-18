# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Tools for manipulating signed PE-COFF binaries"
HOMEPAGE="https://github.com/rhboot/pesign"
SRC_URI="https://github.com/rhboot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:=
	dev-libs/popt
	sys-apps/util-linux
	>=sys-libs/efivar-38
"
DEPEND="${RDEPEND}
	sys-boot/gnu-efi
"
BDEPEND="
	doc? ( app-text/mandoc )
	sys-apps/help2man
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-114-wanalyzer-diagnostic.patch
	"${FILESDIR}"/${PN}-114-no-werror.patch

	"${FILESDIR}"/${P}-format-string.patch

	# Allow disabling docs so we don't need mandoc
	# https://github.com/rhboot/pesign/pull/110
	"${FILESDIR}"/${PN}-114-disable-docs.patch
)

src_compile() {
	emake \
		AR="$(tc-getAR)" \
		ARFLAGS="-cvqs" \
		AS="$(tc-getAS)" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		OBJCOPY="$(tc-getOBJCOPY)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		RANLIB="$(tc-getRANLIB)" \
		rundir="${EPREFIX}/var/run" \
		ENABLE_DOCS=$(usex doc 1 0)
}

src_install() {
	emake DESTDIR="${ED}" VERSION="${PVR}" rundir="${EPREFIX}/var/run" \
		ENABLE_DOCS=$(usex doc 1 0) install
	if use doc; then
		einstalldocs
	fi

	# remove some files that don't make sense for Gentoo installs
	rm -rf "${ED}/etc" "${ED}/var" "${ED}/usr/share/doc/${PF}/COPYING" || die
}
