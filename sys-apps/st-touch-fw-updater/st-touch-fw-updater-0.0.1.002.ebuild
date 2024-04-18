# Copyright 2019 The ChromiumOS Authors
# This file is distributed under the terms of the GNU General Public License v2.

EAPI="7"

inherit cros-common.mk flag-o-matic

DESCRIPTION="STMicroelectronics touchscreen controller firmware updater"
HOMEPAGE="https://github.com/stmicroelectronics-acp/st-touch-fw-updater"
SRC_URI="https://github.com/stmicroelectronics-acp/st-touch-fw-updater/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

src_prepare() {
	# TODO: patch the github repo directly & pull those changes in
	sed -i 's|_FORTIFY_SOURCE=2|_FORTIFY_SOURCE=3|g' "${S}/common.mk" || die
	default
}

src_compile() {
	# FIXME(crbug.com/965691): Remove this when upstream fixes their format
	# strings.
	append-cppflags -Wno-error=format
	emake
}

src_install() {
	dosbin st-touch-fw-updater
}
