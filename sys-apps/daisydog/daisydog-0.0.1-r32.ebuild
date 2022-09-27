# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="4b0c966fb6a35eabd6f06633a5c48ecff27ce2a5"
CROS_WORKON_TREE="8c8ad8ed7b4a24dca5f8e8086ae4e338f4aa159e"
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
