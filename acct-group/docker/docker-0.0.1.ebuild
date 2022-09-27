# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SLOT="0"
KEYWORDS="*"

inherit user

# TODO(crbug.com/1026816): this ebuild is just a placeholder (to satisfy Gentoo
# dependencies) while we wait to implement acct-{group,user} properly.
pkg_setup() {
	enewgroup docker
}
