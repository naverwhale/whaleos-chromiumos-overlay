# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cros-debug meson

DESCRIPTION="Percetto is a C wrapper for Perfetto SDK."
HOMEPAGE="https://github.com/olvaffe/percetto"

SRC_URI="https://github.com/olvaffe/percetto/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="*"
LICENSE="Apache-2.0"
SLOT="0"

COMMON_DEPEND="
	chromeos-base/perfetto:=
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_configure() {
	# If not building with cros-debug, the SDK should be built with NDEBUG as
	# well.
	cros-debug-add-NDEBUG

	local emesonargs=(
		-Dperfetto-sdk="${SYSROOT}/usr/include/perfetto/"
		-Dwerror=false
	)
	meson_src_configure
}
