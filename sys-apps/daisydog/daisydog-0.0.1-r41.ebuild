# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="cd82b41fefe3dbf7fd0bca93aa7fad86938d483f"
CROS_WORKON_TREE="c7bf2d6fe1f02183195ac0c5c5412e948badcd85"
CROS_WORKON_PROJECT="chromiumos/third_party/daisydog"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon toolchain-funcs user

DESCRIPTION="Simple HW watchdog daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/daisydog"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

src_prepare() {
	mkdir -p "$(cros-workon_get_build_dir)"
	default
}

src_configure() {
	tc-export CC
	default
}

_emake() {
	emake -C "$(cros-workon_get_build_dir)" \
		top_srcdir="${S}" -f "${S}"/Makefile "$@"
}

src_compile() {
	_emake
}

src_install() {
	_emake DESTDIR="${D}" install
}

pkg_preinst() {
	enewuser watchdog
	enewgroup watchdog
}
