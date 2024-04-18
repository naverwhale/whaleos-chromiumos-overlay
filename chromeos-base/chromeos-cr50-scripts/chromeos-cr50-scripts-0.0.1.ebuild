# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit udev user

DESCRIPTION="Ebuild to support the Chrome OS Cr50 device."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="generic_tpm2 cr50_onboard ti50_onboard cr50_disable_sleep_in_suspend"

DEPEND="chromeos-base/hwsec-utils"

RDEPEND="
	chromeos-base/ec-utils
	chromeos-base/vboot_reference:=
	!<chromeos-base/chromeos-cr50-0.0.1-r38
"

S="${WORKDIR}"

pkg_preinst() {
	enewuser "rma_fw_keeper"
	enewgroup "rma_fw_keeper"
	enewgroup "suzy-q"
}

create_cr50_script_soft_link() {
	local GSC_BINARY_NAME="$1"
	local CR50_BINARY_NAME="${GSC_BINARY_NAME/gsc/cr50}"
	local CR50_SCRIPT_NAME="$(echo "${CR50_BINARY_NAME}" | sed 's/_/-/g' | \
		sed 's/$/.sh/g')"

	local GSC_BINARY_DIR="/usr/share/cros/hwsec-utils"
	local CR50_SCRIPT_DIR="/usr/share/cros"

	dosym "${GSC_BINARY_DIR}/${GSC_BINARY_NAME}" \
		"${GSC_BINARY_DIR}/${CR50_BINARY_NAME}"
	dosym "${GSC_BINARY_DIR}/${GSC_BINARY_NAME}" \
		"${CR50_SCRIPT_DIR}/${CR50_SCRIPT_NAME}"
}

src_install() {
	local files
	local f

	insinto /etc/init
	files=(
		cr50-metrics.conf
		cr50-result.conf
		cr50-update.conf
	)
	for f in "${files[@]}"; do
		doins "${FILESDIR}/${f}"
	done

	if use cr50_disable_sleep_in_suspend; then
		doins "${FILESDIR}/cr50-disable-sleep.conf"
	fi

	udev_dorules "${FILESDIR}"/99-cr50.rules

	exeinto /usr/share/cros

	# TODO(b/289003370): The gsc-constants.sh is referenced in multiple
	# locations in the factory related flow.
	if use ti50_onboard; then
		f="ti50-constants.sh"
	elif use cr50_onboard || use generic_tpm2; then
		f="cr50-constants.sh"
	else
		die "Neither GSC nor generic TPM2 is used"
	fi
	newexe "${FILESDIR}/${f}" "gsc-constants.sh"

	# TODO(b/289003370): Remove the script symlink one all callers are calling
	# rust binaries directly.
	create_cr50_script_soft_link "gsc_flash_log"
	create_cr50_script_soft_link "gsc_read_rma_sn_bits"
	create_cr50_script_soft_link "gsc_reset"
	create_cr50_script_soft_link "gsc_set_board_id"
	create_cr50_script_soft_link "gsc_set_sn_bits"
	create_cr50_script_soft_link "gsc_update"
	create_cr50_script_soft_link "gsc_verify_ro"

	insinto /opt/google/cr50/ro_db
	doins "${FILESDIR}"/ro_db/*.db
}
