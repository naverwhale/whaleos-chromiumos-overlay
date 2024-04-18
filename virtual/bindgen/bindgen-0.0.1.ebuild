# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Prevent needing to build dev-rust/bindgen for each board."
# For ebuilds that need to BDEPEND on dev-rust/bindgen, add:
#     DEPEND="virtual/bindgen:="
#     BDEPEND="dev-rust/bindgen"
# This will trigger a rebuild when the slot of virtual/bindgen changes.

LICENSE="metapackage"
KEYWORDS="*"

SLOT="0/${PVR}"
