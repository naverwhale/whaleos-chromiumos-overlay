# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="beefcc767427751cf1343c1a944c5dbce7aabfa2"
CROS_WORKON_TREE="d2f7a20eeeca7497d1af6de7e1afcb217fc28aae"
CROS_WORKON_PROJECT="chromiumos/platform/microbenchmarks"
CROS_WORKON_LOCALNAME="../platform/microbenchmarks"

inherit cros-workon cros-common.mk

DESCRIPTION="Home for microbenchmarks designed in-house."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/microbenchmarks"

LICENSE="BSD-Google"
KEYWORDS="*"

src_install() {
	dobin "${OUT}"/memory-eater/memory-eater
}
