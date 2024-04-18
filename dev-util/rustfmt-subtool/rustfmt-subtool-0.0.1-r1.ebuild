# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-subtool cros-workon

DESCRIPTION="Subtools definition to export rustfmt from dev-lang/rust-host."
HOMEPAGE="https://github.com/rust-lang/rustfmt"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE=""

# This ebuild is kept separate from dev-lang/rust-host (which installs rustfmt)
# in order to decouple from the complications around revbumping toolchains. When
# the rustfmt subtool has stabilized, and toolchain revbumps are simpler, the
# `src_install` here should be merged into the rust-host ebuild.
DEPEND="dev-lang/rust-host"

src_install() {
	cros-subtool_src_install "${FILESDIR}/rustfmt_subtool.textproto"
}
