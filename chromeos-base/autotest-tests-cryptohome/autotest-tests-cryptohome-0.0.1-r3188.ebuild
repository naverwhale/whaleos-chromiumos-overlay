# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="5235bb1a8fd6c8c8b8a5741bbd16e35653db8e16"
CROS_WORKON_TREE="00f5fa22a82bd227716dc66ee7996ec65d6b19c6"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

inherit cros-workon autotest

DESCRIPTION="Cryptohome autotests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

COMMON_DEPEND="
	!<chromeos-base/autotest-tests-0.0.3
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/cryptohome-dev-utils
"

DEPEND="
	${COMMON_DEPEND}
"

IUSE_TESTS="
	+tests_platform_CryptohomeFio
	+tests_platform_CryptohomeStress
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
