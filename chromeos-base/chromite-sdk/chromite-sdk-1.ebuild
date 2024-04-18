# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# This is separate from the chromite ebuild currently so that we *don't* track
# the chromite repo directly.  This stuff rarely changes, so we don't want to
# throw useless churn into the SDK.

EAPI="7"

PYTHON_COMPAT=( python3_{6..9} )

inherit cros-constants python-r1

DESCRIPTION="Blend chromite bits into the SDK"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/chromite/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${PYTHON_DEPS}"

# A stub to force removal of the symlinks.
src_install() { :; }
