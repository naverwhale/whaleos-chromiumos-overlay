# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs cros-sanitizers

DESCRIPTION="FUSE file system to navigate, extract, create and modify ZIP archives"
HOMEPAGE="https://bitbucket.org/agalanin/fuse-zip"
SRC_URI="https://bitbucket.org/agalanin/${PN}/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	>=chromeos-base/chrome-icu-89
	dev-libs/libzip:=
	sys-fs/fuse:0
"
RDEPEND="${DEPEND}"

RESTRICT="test"

DOCS=( changelog README.md )

PATCHES=(
	"${FILESDIR}/${PN}-0.4.5-makefile.patch"
	"${FILESDIR}/${PN}-0.7.0-makefile.patch"
	"${FILESDIR}/${PN}-0.7.0-fix-unknown-file-types.patch"
	"${FILESDIR}/${PN}-0.7.0-fix-utf8-filenames.patch"
	"${FILESDIR}/${PN}-0.7.0-error-reporting.patch"
	"${FILESDIR}/${PN}-0.7.0-password.patch"
	"${FILESDIR}/${PN}-0.7.0-no-symlinks.patch"
	"${FILESDIR}/${PN}-0.7.0-deduplicate-filenames.patch"
	"${FILESDIR}/${PN}-0.7.0-guess-encoding.patch"
	"${FILESDIR}/${PN}-0.7.0-rolling-cache.patch"
	"${FILESDIR}/${PN}-0.7.0-chrome-icu.patch"
)

src_compile() {
	sanitizers-setup-env
	tc-export PKG_CONFIG
	emake CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS} ${LDFLAGS}"
}

src_install() {
	default
	doman fuse-zip.1
}
