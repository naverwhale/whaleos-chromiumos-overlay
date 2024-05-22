# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages needed in the SDK's rust registry for the cargo workflow."
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~*"

# Note this should primarily be dependencies with a patch.crates-io modifier
# referencing the chroot's cros_rust_registry.
RDEPEND="
	dev-rust/data_model
	dev-rust/third-party-crates-src
	media-sound/audio_streams
"
