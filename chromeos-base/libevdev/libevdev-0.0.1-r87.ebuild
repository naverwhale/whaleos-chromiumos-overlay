# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="1f777246665809009a50a37545322ca5954b08a8"
CROS_WORKON_TREE="138af2f36782669511e8c787515dfec497a8bceb"
CROS_WORKON_PROJECT="chromiumos/platform/libevdev"
CROS_WORKON_USE_VCSID=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform/libevdev"

inherit cros-debug cros-sanitizers cros-workon cros-common.mk

DESCRIPTION="evdev userspace library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/libevdev"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="-asan"
SLOT="0/1"

src_configure() {
	sanitizers-setup-env
	cros-common.mk_src_configure
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install
}
