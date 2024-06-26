# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# NB: This package should be kept to an absolute minimum.  We do not want the
# dev image to deviate from the base rootfs that is released to the world.
# If you really need rootfs modifications, use chromeos-test-root and a test
# image instead.

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="platform/empty-project"

inherit cros-workon

DESCRIPTION="Install packages that must live in the rootfs in dev images."
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE="pvs-disable-ssh"

RDEPEND="
	!pvs-disable-ssh? ( chromeos-base/openssh-server-init )
	chromeos-base/virtual-usb-printer
	virtual/chromeos-bsp-dev-root
"
