# Copyright 2010 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="4213d38358458b14446fcf54c04631d177eb5bc5"
CROS_WORKON_TREE="76eb44de95e1aa938ca4d912afa0eb9c442a73fd"
CROS_WORKON_PROJECT="chromiumos/third_party/trousers"
CROS_WORKON_EGIT_BRANCH="master-0.3.13"

inherit cros-workon autotest

DESCRIPTION="Trousers TPM tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/trousers/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
DEPEND="
	app-crypt/trousers
	!<chromeos-base/autotest-tests-0.0.1-r1521
"
RDEPEND="${DEPEND}"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_hardware_TPM
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=trousers

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest

src_compile() {
	# for Makefile
	export TROUSERS_DIR=${WORKDIR}/${P}
	autotest_src_compile
}

