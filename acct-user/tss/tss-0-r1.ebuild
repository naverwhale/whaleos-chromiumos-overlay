# Copyright 2019-2020 Gentoo Authors# Distributed under the terms of the GNU General Public License v2
EAPI=7
SLOT="0"
KEYWORDS="*"
inherit user
pkg_setup() {
   enewuser tss
}
