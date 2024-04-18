# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="1073e9376a461c1913c2b9465950565a5592ec2f"
CROS_WORKON_TREE="ff60736acc1609a825780f50426b17b44b988ee4"
CROS_WORKON_PROJECT="chromiumos/platform/graphics"
CROS_WORKON_LOCALNAME="platform/graphics"

inherit cros-workon

DESCRIPTION="Installs utils for graphics tests."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/graphics/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE=""

INSTALL_DIR="/usr/local/graphics"

src_install() {
	insinto "${INSTALL_DIR}"
	# Install scripts running basic GPU tests particularly used in reven manual testing.
	doins -r src/reven-manual-testing

	# doins doesn't copy perms, mark the scripts executable.
	fperms 755 "${INSTALL_DIR}"/reven-manual-testing/reven-gpu-test.sh
}
