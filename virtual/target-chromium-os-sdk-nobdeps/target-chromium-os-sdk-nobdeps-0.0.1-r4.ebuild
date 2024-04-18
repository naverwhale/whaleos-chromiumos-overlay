# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages that are needed inside the SDK, but where we only
want to install a binpkg.  We never want to install build-time deps or recompile
from source unless the user explicitly requests it."
HOMEPAGE="http://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE=""

# The vast majority of packages should not be listed here!  You most likely
# want to update virtual/target-chromium-os-sdk instead.  Only list packages
# here that should not have build-time deps installed (e.g. Haskell leaf
# packages), or otherwise want stronger guarantees that we will only install as
# a binpkg (e.g., because rebuilding is very slow).  Please document the reason
# next to each dependency.
RDEPEND=""

# Avoid very slow rebuilds, and avoid pulling Haskell compiler.
# Needed only for linting.
RDEPEND="${RDEPEND}
	dev-util/shellcheck
"

# Avoid very slow toolchain rebuilds. Relies on host compiler, but not
# cross-compilers.
RDEPEND="${RDEPEND}
	dev-embedded/coreboot-sdk
"

# Avoid very slow toolchain rebuilds. Relies on host compiler, but not
# cross-compilers.
RDEPEND="${RDEPEND}
	dev-embedded/ti50-sdk
"

# Avoid very slow rebuilds.
# Needed only for fps testing right now.
RDEPEND="${RDEPEND}
	app-emulation/renode
"
