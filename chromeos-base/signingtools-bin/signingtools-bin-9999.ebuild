# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="platform/empty-project"

inherit cros-constants cros-workon

DESCRIPTION="Builds standalone bundle of signing tools"

LICENSE="BSD-Google GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE=""

DEPEND="
	sys-apps/coreboot-utils
	chromeos-base/vboot_reference
	chromeos-base/verity
"
RDEPEND=""

bundle_tool() {
	"${CHROMITE_DIR}/bin/lddtree" \
		"${SYSROOT}$1" \
		--bindir "/" \
		--libdir "/lib" \
		--generate-wrappers \
		--copy-to-tree "${D}/usr/share/signingtools-bin/" || die
}

src_install() {
	local bin usrbins=(cbfstool futility verity)

	for bin in "${usrbins[@]}"; do
		bundle_tool "/usr/bin/${bin}"
	done
}
