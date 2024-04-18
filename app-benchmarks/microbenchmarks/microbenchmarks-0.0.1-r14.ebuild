# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="fe0bf1eaf40232031a6b04b76b2a07b38b0bfef5"
CROS_WORKON_TREE="319d9c4f7c85e0c6430483bf0b431edfc3991a29"
CROS_WORKON_PROJECT="chromiumos/platform/microbenchmarks"
CROS_WORKON_LOCALNAME="../platform/microbenchmarks"

inherit cros-workon cros-common.mk cros-sanitizers

DESCRIPTION="Home for microbenchmarks designed in-house."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/microbenchmarks"

LICENSE="BSD-Google"
KEYWORDS="*"

src_configure() {
	sanitizers-setup-env
	default
}

src_install() {
	dobin "${OUT}"/memory-eater/memory-eater
}
