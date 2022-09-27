# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk syslog-cat .gn"

PLATFORM_SUBDIR="syslog-cat"

inherit cros-workon platform

DESCRIPTION="Simple command to forward stdout/err to syslog"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/syslog-cat"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"
IUSE=""

src_install() {
	platform_install
}

platform_pkg_test() {
	platform test_all
}

