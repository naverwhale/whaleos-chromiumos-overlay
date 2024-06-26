# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

CROS_WORKON_PROJECT="chromiumos/third_party/fwupd"
CROS_WORKON_EGIT_BRANCH="fwupd-1.9.6"

inherit python-any-r1 cros-workon linux-info meson udev user cros-sanitizers

DESCRIPTION="Aims to make updating firmware on Linux automatic, safe and reliable"
HOMEPAGE="https://fwupd.org"
#SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~*"
CONFIG_FILE="fwupd.conf"

if [[ ${PV} == "9998" ]] ; then
	EGIT_REPO_URI="https://github.com/fwupd/fwupd"
	EGIT_BRANCH="main"
	inherit git-r3
	# shellcheck disable=SC5000 # This is only for the non-cros-workon 9998
	# revision, not for a true cros-workon.
	KEYWORDS="*"
fi

IUSE="agent amt +archive bash-completion bluetooth cbor cfm dell +dummy elogind fastboot flashrom +gnutls gtk-doc +gusb +gpg gpio introspection logitech lzma minimal modemmanager nls nvme pkcs7 policykit spi +sqlite synaptics systemd test uefi ufs"
REQUIRED_USE="
	dell? ( uefi )
	fastboot? ( gusb )
	logitech? ( gusb )
	minimal? ( !introspection )
	modemmanager? ( gusb )
	spi? ( lzma )
	synaptics? ( gnutls )
	test? ( archive gusb )
	uefi? ( gnutls )
"

USER_DEPS="
	acct-user/chronos
	acct-user/fwupd
	acct-group/fwupd
	acct-user/cros_healthd
	acct-user/cfm-firmware-updaters
"

# shellcheck disable=SC2016
BDEPEND="
	app-arch/gcab
	dev-libs/glib
	>=dev-util/meson-0.60.0
	virtual/pkgconfig
	gtk-doc? ( >=dev-util/gi-docgen-2021.1 )
	bash-completion? ( >=app-shells/bash-completion-2.0 )
	introspection? ( dev-libs/gobject-introspection )
	$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
	')
	sys-devel/gettext
	${USER_DEPS}
"
COMMON_DEPEND="
	>=app-arch/gcab-1.0
	app-arch/xz-utils
	>=dev-libs/glib-2.68:2
	>=dev-libs/json-glib-1.6.0
	>=dev-libs/libgudev-232:=
	>=dev-libs/libjcat-0.1.4[gpg?,pkcs7?]
	>=dev-libs/libxmlb-0.3.6:=[introspection?]
	>=net-misc/curl-7.62.0
	archive? ( app-arch/libarchive:= )
	cbor? ( >=dev-libs/libcbor-0.7.0:= )
	dell? (
		>=app-crypt/tpm2-tss-2.0
		>=sys-libs/libsmbios-2.4.0
	)
	elogind? ( >=sys-auth/elogind-211 )
	flashrom? ( sys-apps/flashrom )
	gnutls? ( >=net-libs/gnutls-3.6.0 )
	gusb? ( >=dev-libs/libgusb-0.3.8[introspection?] )
	logitech? ( dev-libs/protobuf-c:= )
	lzma? ( app-arch/xz-utils )
	modemmanager? ( net-misc/modemmanager[mbim,qmi] )
	policykit? ( >=sys-auth/polkit-0.114 )
	sqlite? ( dev-db/sqlite )
	systemd? ( >=sys-apps/systemd-211 )
	uefi? (
		sys-apps/fwupd-efi
		sys-boot/efibootmgr
		sys-libs/efivar
	)
"
RDEPEND="
	${COMMON_DEPEND}
	${USER_DEPS}
	sys-apps/dbus
"

DEPEND="
	${COMMON_DEPEND}
	x11-libs/pango[introspection?]
"

python_check_deps() {
	python_has_version -b "dev-python/jinja[${PYTHON_USEDEP}]"
}

pkg_setup() {
	if use nvme ; then
		kernel_is -ge 4 4 || die "NVMe support requires kernel >= 4.4"
	fi
}

src_prepare() {
	default
	# c.f. https://github.com/fwupd/fwupd/issues/1414
	sed -e "/test('thunderbolt-self-test', e, env: test_env, timeout : 120)/d" \
		-i plugins/thunderbolt/meson.build || die

	sed -e "/install_dir.*'doc'/s/doc/gtk-doc/" \
		-i docs/meson.build || die

	if ! use nls ; then
		echo > po/LINGUAS || die
	fi
}

src_configure() {
	sanitizers-setup-env

	local plugins=(
		-Dplugin_emmc="enabled"
		-Dplugin_parade_lspcon="enabled"
		-Dplugin_pixart_rf="enabled"
		-Dplugin_powerd="enabled"
		-Dplugin_realtek_mst="enabled"
		# TODO(b/276484917): the splash feature doesn't build
		# successfully yet.
		-Dplugin_uefi_capsule_splash="false"
		$(meson_feature amt plugin_intel_me)
		$(meson_feature fastboot plugin_fastboot)
		$(meson_use dummy plugin_dummy)
		$(meson_feature flashrom plugin_flashrom)
		$(meson_feature gpio plugin_gpio)
		$(meson_feature gusb plugin_uf2)
		$(meson_feature logitech plugin_logitech_bulkcontroller)
		$(meson_feature logitech plugin_logitech_scribe)
		$(meson_feature logitech plugin_logitech_tap)
		$(meson_feature modemmanager plugin_modem_manager)
		$(meson_feature nvme plugin_nvme)
		$(meson_use spi plugin_intel_spi)
		$(meson_feature synaptics plugin_synaptics_mst)
		$(meson_feature synaptics plugin_synaptics_rmi)
		$(meson_feature uefi plugin_uefi_capsule)
		$(meson_feature uefi plugin_uefi_pk)
		$(meson_feature ufs plugin_scsi)
	)

	local emesonargs=(
		--localstatedir "${EPREFIX}"/var
		-Dauto_features="disabled"
		-Dbuild="$(usex minimal standalone all)"
		-Dcompat_cli="$(usex agent true false)"
		-Dcurl="enabled"
		-Defi_binary="false"
		-Dgudev="enabled"
		-Dman="true"
		-Dsupported_build="enabled"
		-Dudevdir="${EPREFIX}$(get_udevdir)"
		$(meson_feature archive libarchive)
		$(meson_use bash-completion bash_completion)
		$(meson_feature bluetooth bluez)
		$(meson_feature cbor)
		$(meson_feature elogind)
		$(meson_feature gnutls)
		$(meson_feature gtk-doc docs)
		$(meson_feature gusb)
		$(meson_feature lzma)
		$(meson_feature introspection)
		$(meson_feature policykit polkit)
		$(meson_feature sqlite)
		$(meson_feature systemd)
		$(meson_use test tests)

		"${plugins[@]}"
	)
	use uefi && emesonargs+=( -Defi_os_dir="chromeos" )
	export CACHE_DIRECTORY="${T}"
	meson_src_configure
}

src_test() {
	LC_ALL="C" meson_src_test
}

src_install() {
	meson_src_install

	# Fix generated file user permissions.
	sudo chown -R fwupd "${ED}"/etc/fwupd || die

	# Add the local mirror as base url
	local local_mirror_url="https://storage.googleapis.com/chromeos-localmirror/lvfs/"
	echo "FirmwareBaseURI=${local_mirror_url}" >> "${ED}"/etc/${PN}/remotes.d/lvfs.conf || die

	# Enable vendor-directory remote with local firmware
	sed 's/Enabled=false/Enabled=true/' -i "${ED}"/etc/${PN}/remotes.d/vendor-directory.conf || die

	# Set Metadata to point to the mirror
	local uri="https://storage.googleapis.com/chromeos-localmirror/lvfs/firmware.xml.gz"
	sed 's,MetadataURI=.*,MetadataURI='"${uri}"',' -i "${ED}"/etc/${PN}/remotes.d/lvfs.conf || die

	# Allow chronos and fwupd to issue installs/updates
	# Allow cros_healthd to obtain instanceIds and serials
	local chronos_uid=$(egetent passwd chronos | cut -d: -f3)
	local cros_healthd_uid=$(egetent passwd cros_healthd | cut -d: -f3)
	local fwupd_uid=$(egetent passwd fwupd | cut -d: -f3)
	echo "TrustedUids=${chronos_uid};${cros_healthd_uid};${fwupd_uid}" >> "${ED}"/etc/${PN}/${CONFIG_FILE} || die

	# Set trusted-reports flag if Distro is chromeos and if the firmware is
	# uploaded by one of: Google, Allion or the firmware owner themselves
	local cros_distro="DistroId=chromeos"
	local google_vendorid="${cros_distro}&VendorId=16"
	local allion_vendorid="${cros_distro}&VendorId=1923"
	local firmware_owner_vendorid="${cros_distro}&VendorId=\$OEM"
	echo "TrustedReports=${google_vendorid};${allion_vendorid};${firmware_owner_vendorid}" >> "${ED}"/etc/${PN}/${CONFIG_FILE} || die

	# Install udev rules to fix user permissions.
	udev_dorules "${FILESDIR}"/90-fwupd.rules

	# Change D-BUS owner for org.freedesktop.fwupd
	sed 's/root/fwupd/' -i "${ED}"/usr/share/dbus-1/system.d/org.freedesktop.fwupd.conf || die

	# Install D-BUS service for org.freedesktop.fwupd to enable D-BUS activation
	insinto /usr/share/dbus-1/system-services
	doins "${FILESDIR}"/org.freedesktop.fwupd.service

	insinto /etc/init
	# Install upstart script for fwupd daemon.
	doins "${FILESDIR}"/init/fwupd.conf
	# Install upstart script for activating firmware update on logout/shutdown.
	doins "${FILESDIR}"/init/fwupdtool-activate.conf
	# Install upstart script for automatic firmware update on device plug-in.
	doins "${FILESDIR}"/init/fwupdtool-update.conf

	insinto /usr/lib/tmpfiles.d
	# Install tmpfiles script for generating the necessary directories
	doins "${FILESDIR}"/tmpfiles.d/fwupd.conf

	# Set Best Know Configuration tag to chromium (See cros-fwupd.eclass)
	echo "HostBkc=chromium" >> "${ED}"/etc/${PN}/${CONFIG_FILE} || die

	exeinto /usr/share/cros/init
	doexe "${FILESDIR}"/fwupd-at-boot.sh

	# Install rsyslog config.
	insinto /etc/rsyslog.d
	doins "${FILESDIR}"/rsyslog.fwupd.conf

	if ! use minimal ; then
		if ! use systemd ; then
			# Don't timeout when fwupd is running (#673140)
			echo "IdleTimeout=0" >> "${ED}"/etc/${PN}/${CONFIG_FILE} || die
		fi
	fi

	if use cfm ; then
		# Allow firmware from CfM mirror to be installed by fwupd
		sed '/^OnlyTrusted=/s/true/false/' -i "${ED}"/etc/${PN}/${CONFIG_FILE} || die
		# Allow cfm-firmware-updaters to issue installs/updates
		local cfm_firmware_updaters_uid=$(egetent passwd cfm-firmware-updaters | cut -d: -f3)
		sed "/^TrustedUids=.*/s/$/;${cfm_firmware_updaters_uid}/" -i "${ED}"/etc/${PN}/${CONFIG_FILE} || die
	fi

	# For UEFI, set the ESP mount point in the config.
	if use uefi ; then
		echo "EspLocation=/efi" >> "${ED}/etc/${PN}/${CONFIG_FILE}" || die
	fi
}
