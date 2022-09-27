# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="6ad2bf259420afb9c7caa793054f36d1200109aa"
CROS_WORKON_TREE="4d6d8f07299def567532377e3caa17192b4bddfb"
inherit cros-constants

CROS_WORKON_REPO="${CROS_GIT_HOST_URL}"
CROS_WORKON_PROJECT="chromiumos/platform/tast-tests"
CROS_WORKON_LOCALNAME="platform/tast-tests"
CROS_WORKON_SUBTREE="vars"
inherit cros-workon

DESCRIPTION="All Tast static variables"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="virtual/tast-vars"
DEPEND="${RDEPEND}"

src_install() {
	insinto /etc/tast/vars/public
	doins -r vars/*
}
