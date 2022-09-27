# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SLOT="0"
KEYWORDS="*"

inherit user

# TODO(crbug/1026816): this is a placeholder (to satisfy Gentoo
#  openssh dependencies) while acct-{group,user} are implemented.
pkg_setup() {
	enewgroup sshd
}
