# Copyright 2017 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

inherit eutils toolchain-funcs

DESCRIPTION="Infineon TPM firmware updater"
SRC_URI="gs://chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="BSD-Infineon LICENSE.infineon-firmware-updater-TCG"
SLOT="0"
KEYWORDS="*"
IUSE="tpm_slb9655_v4_31"

DEPEND="test? ( dev-util/shunit2 )"

RDEPEND="
	dev-libs/openssl:0=
	tpm_slb9655_v4_31? ( chromeos-base/ec-utils )
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}"/makefile-fixes.patch
	"${FILESDIR}"/unlimited-log-file-size.patch
	"${FILESDIR}"/dry-run-option.patch
	"${FILESDIR}"/change_default_password.patch
	"${FILESDIR}"/retry-send-on-ebusy.patch
	"${FILESDIR}"/ignore-error-on-complete-option.patch
	"${FILESDIR}"/update-type-ownerauth.patch
	"${FILESDIR}"/openssl-1.1.patch
	"${FILESDIR}"/wno-error.patch
)

src_configure() {
	# Disable -Wstrict-prototypes, b/230345382.
	append-flags -Wno-strict-prototypes
	tc-export AR CC
}

src_compile() {
	emake -C TPMFactoryUpd
}

src_test() {
	"${FILESDIR}"/tpm-firmware-updater-test || die
}

src_install() {
	newsbin TPMFactoryUpd/TPMFactoryUpd infineon-firmware-updater
	dosbin "${FILESDIR}"/tpm-firmware-updater
	dosbin "${FILESDIR}"/tpm-firmware-locate-update
	dosbin "${FILESDIR}"/tpm-firmware-update-cleanup

	insinto /etc/init
	doins "${FILESDIR}"/tpm-firmware-check.conf
	doins "${FILESDIR}"/tpm-firmware-update.conf
	doins "${FILESDIR}"/send-tpm-firmware-update-metrics.conf
	exeinto /usr/share/cros/init
	doexe "${FILESDIR}"/tpm-firmware-check.sh
	doexe "${FILESDIR}"/tpm-firmware-update.sh
	doexe "${FILESDIR}"/tpm-firmware-update-factory.sh
}
