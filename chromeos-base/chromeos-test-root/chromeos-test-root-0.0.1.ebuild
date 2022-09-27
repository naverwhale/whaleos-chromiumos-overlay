# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Install packages that must live in the rootfs in test images"
# 1) Normally, test image packages are merged into the stateful partition
# 2) Some test packages require files in the root file system (e.g.
#    upstart jobs must live in /etc/init).
# 3) There's an extra emerge command for this package in
#    build_library/test_image_util.sh that specifically merges this
#    package into the root before merging the remaining test packages
#    into stateful.
HOMEPAGE="http://www.chromium.org/"
KEYWORDS="*"
LICENSE="BSD-Google"
SLOT="0"
# Include bootchart in the test image unless explicitly disabled. Bootchart is
# disabled by default and enabled by the "cros_bootchart" kernel arg.
IUSE="+bootchart"

RDEPEND="
	bootchart? ( app-benchmarks/bootchart )
	chromeos-base/chromeos-test-init
	chromeos-base/update-utils
	virtual/chromeos-test-testauthkeys
	virtual/chromeos-bsp-test-root
"
