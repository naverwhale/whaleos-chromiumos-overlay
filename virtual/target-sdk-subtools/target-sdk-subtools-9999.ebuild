# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages updated by the SDK subtools builder before it
looks for subtool definitions to bundle and upload."
# TODO(build): Point to subtools doc once it's available.
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~*"
IUSE=""

RDEPEND="
	dev-util/rustfmt-subtool
	dev-util/shellcheck
"

DEPEND="${RDEPEND}"
