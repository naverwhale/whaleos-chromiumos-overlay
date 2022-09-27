# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages that are needed inside the Chromium OS base (release)"
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os instead.
# Note: You almost never want to use + here to enable settings by default.
# Please see https://crrev.com/c/2776455 as an example instead.
IUSE="
	asan
	arc-camera1
	arc-camera3
	biod
	bluetooth
	bootchart
	buffet
	cellular
	compupdates
	containers
	cr50_onboard
	+cras
	+crash_reporting
	+cros_disks
	cros_embedded
	cups
	+debugd
	diagnostics
	dlc
	dlc_test
	dlp
	dns-proxy
	dptf
	eclog
	factory_branch
	featured
	federated_service
	floss
	+fonts
	fpstudy
	fuzzer
	fwupd
	hammerd
	iioservice
	ime
	input_devices_evdev
	intel_lpe
	iwlwifi_rescan
	kerberos_daemon
	kvm_host
	lacros_rootfs
	manatee
	media_perception
	memd
	missive
	mist
	minios
	mmc
	secanomalyd
	modemfwd
	ml_service
	hps
	mtd
	+network_time
	nfc
	os_install_service
	pam
	pciguard
	perfetto
	postscript
	+power_management
	+profile
	racc
	+readahead
	resourced
	rmad
	scanner
	selinux
	+shill
	sirenia
	smbprovider
	+spaced
	+syslog
	+system_locales
	system_proxy
	systemd
	ti50_onboard
	touchview
	+tpm
	-tpm2
	+trim_supported
	typecd
	ubsan
	usb_bouncer
	usbguard
	+vpn
	watchdog
"

REQUIRED_USE="
	cellular? ( shill )
	modemfwd? ( cellular )
"

################################################################################
#
# READ THIS BEFORE ADDING PACKAGES TO THIS EBUILD!
#
################################################################################
#
# Every chromeos dependency (along with its dependencies) is included in the
# release image -- more packages contribute to longer build times, a larger
# image, slower and bigger auto-updates, increased security risks, etc. Consider
# the following before adding a new package:
#
# 1. Does the package really need to be part of the release image?
#
# Some packages can be included only in the developer or test images, i.e., the
# target-os-dev or chromeos-test ebuilds. If the package will eventually be used
# in the release but it's still under development, consider adding it to
# target-os-dev initially until it's ready for production.
#
# 2. Why is the package a direct dependency of the chromeos ebuild?
#
# It makes sense for some packages to be included as a direct dependency of the
# chromeos ebuild but for most it doesn't. The package should be added as a
# direct dependency of the ebuilds for all packages that actually use it -- in
# time, this ensures correct builds and allows easier cleanup of obsolete
# packages. For example, if a utility will be invoked by the session manager,
# its package should be added as a dependency in the chromeos-login ebuild. If
# the package really needs to be a direct dependency of the chromeos ebuild,
# consider adding a comment why the package is needed and how it's used.
#
# 3. Are all default package features and dependent packages needed?
#
# The release image should include only packages and features that are needed in
# the production system. Often packages pull in features and additional packages
# that are never used. Review these and consider pruning them (e.g., through USE
# flags).
#
# 4. What is the impact on the image size?
#
# Before adding a package, evaluate the impact on the image size. If the package
# and its dependencies increase the image size significantly, consider
# alternative packages or approaches.
#
# 5. Is the package needed on all targets?
#
# If the package is needed only on some target boards, consider making it
# conditional through USE flags in the board overlays.
#
# Variable Naming Convention:
# ---------------------------
# CROS_COMMON_* : Dependencies common to all CrOS flavors
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, etc.)
################################################################################

################################################################################
#
# Per Package Comments:
# --------------------
# Please add any comments specific to why certain packages are
# pulled into the dependecy here. This is optional and required only when
# the dependency isn't obvious
#
################################################################################

################################################################################
#
# Dependencies common to all CrOS flavors (embedded, regular).
# Everything in here should be behind a USE flag.
#
################################################################################
RDEPEND="
	input_devices_evdev? ( app-misc/evtest )
	syslog? (
		app-admin/rsyslog
		chromeos-base/croslog
		chromeos-base/bootid-logger
	)
	biod? ( chromeos-base/biod )
	fpstudy? ( chromeos-base/fingerprint_study )
	compupdates? ( chromeos-base/imageloader )
	dlc? ( chromeos-base/dlcservice )
	dlc_test? (
		chromeos-base/sample-dlc
		chromeos-base/test-dlc
	)
	bluetooth? ( net-wireless/bluez )
	floss? ( net-wireless/floss )
	bootchart? ( app-benchmarks/bootchart )
	tpm? (
		app-crypt/trousers
		chromeos-base/chaps
	)
	tpm2? ( chromeos-base/trunks )
	pam? ( virtual/chromeos-auth-config )
	federated_service? ( chromeos-base/federated-service )
	fonts? ( chromeos-base/chromeos-fonts )
	chromeos-base/chromeos-installer
	chromeos-base/dev-install
	os_install_service? ( chromeos-base/os_install_service )
	perfetto? ( chromeos-base/perfetto )
	crash_reporting? ( chromeos-base/crash-reporter )
	missive? ( chromeos-base/missive )
	mist? ( chromeos-base/mist )
	modemfwd? ( chromeos-base/modemfwd )
	buffet? ( chromeos-base/buffet )
	containers? ( chromeos-base/run_oci )
	cros_disks? ( chromeos-base/cros-disks )
	debugd? ( chromeos-base/debugd )
	diagnostics? ( chromeos-base/diagnostics )
	dlp? ( chromeos-base/dlp )
	kerberos_daemon? ( chromeos-base/kerberos )
	scanner? ( chromeos-base/lorgnette )
	ml_service? ( chromeos-base/ml )
	hps? (
		chromeos-base/hpsd
		!asan? (
			!ubsan? ( chromeos-base/hps-firmware )
		)
	)
	hammerd? ( chromeos-base/hammerd )
	racc? (
		chromeos-base/hardware_verifier
		chromeos-base/runtime_probe
	)
	rmad? ( chromeos-base/rmad )
	iioservice? ( chromeos-base/iioservice )
	media_perception? ( chromeos-base/mri_package )
	memd? ( chromeos-base/memd )
	power_management? ( chromeos-base/power_manager )
	!chromeos-base/platform2
	profile? ( chromeos-base/quipper )
	resourced? ( chromeos-base/resourced )
	selinux? ( chromeos-base/selinux-policy )
	shill? ( >=chromeos-base/shill-0.0.1-r2205 )
	manatee? ( chromeos-base/sirenia )
	sirenia? ( chromeos-base/sirenia )
	spaced? ( chromeos-base/spaced )
	usb_bouncer? ( chromeos-base/usb_bouncer )
	chromeos-base/update_engine
	vpn? ( chromeos-base/vpn-manager )
	cras? (
		media-sound/adhd
		media-sound/cras_tests
	)
	trim_supported? ( chromeos-base/chromeos-trim )
	network_time? ( net-misc/tlsdate )
	iwlwifi_rescan? ( net-wireless/iwlwifi_rescan )
	nfc? ( net-wireless/neard chromeos-base/neard-configs )
	readahead? ( sys-apps/ureadahead )
	pam? ( sys-auth/pam_pwdfile )
	watchdog? ( sys-apps/daisydog )
	mtd? ( sys-fs/mtd-utils )
	cups? ( virtual/chromium-os-printing )
	touchview? (
		!iioservice? ( chromeos-base/chromeos-accelerometer-init )
	)
	system_locales? ( chromeos-base/system-locales )
	system_proxy? ( chromeos-base/system-proxy )
	eclog? ( chromeos-base/timberslide )
	chromeos-base/chromeos-machine-id-regen
	systemd? ( sys-apps/systemd )
	!systemd? ( sys-apps/systemd-tmpfiles )
	usbguard? ( sys-apps/usbguard )
	kvm_host? (
		chromeos-base/crosdns
		chromeos-base/crostini_client
		chromeos-base/vm_host_tools
		chromeos-base/termina-dlc
	)
	sys-kernel/linux-firmware
	virtual/chromeos-bsp
	virtual/chromeos-firewall
	!factory_branch? ( virtual/chromeos-firmware )
	virtual/chromeos-interface
	virtual/chromeos-regions
	virtual/implicit-system
	virtual/linux-sources
	virtual/modutils
	virtual/service-manager
	cr50_onboard? (
		chromeos-base/chromeos-cr50
		chromeos-base/u2fd
	)
	ti50_onboard? (
		chromeos-base/chromeos-ti50
		chromeos-base/u2fd
	)
	ime? (
		app-i18n/chinese-input
		app-i18n/keyboard-input
		app-i18n/japanese-input
		app-i18n/hangul-input
	)
	fuzzer? ( virtual/target-fuzzers )
	!dev-python/socksipy
	arc-camera1? ( chromeos-base/cros-camera )
	arc-camera3? ( chromeos-base/cros-camera )
	fwupd? (
		sys-apps/fwupd
		mmc? ( sys-firmware/mmc-firmware )
	)
	smbprovider? (
		chromeos-base/smbfs
		chromeos-base/smbprovider
	)
	typecd? ( chromeos-base/typecd )
	pciguard? ( chromeos-base/pciguard )
	minios? ( chromeos-base/minios )
	secanomalyd? ( chromeos-base/secanomalyd )
	lacros_rootfs? ( chromeos-base/chromeos-lacros )
	dns-proxy? ( chromeos-base/dns-proxy )
	featured? ( chromeos-base/featured )
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
#
# Comments on individual packages:
# --------------------------------
# app-editors/vim:
# Specifically include the editor we want to appear in chromeos images, so that
# it is deterministic which editor is chosen by 'virtual/editor' dependencies
# (such as in the 'sudo' package).  See crosbug.com/5777.
#
# app-shells/bash:
# We depend on dash for the /bin/sh shell for runtime speeds, but we also
# depend on bash to make the dev mode experience better.  We do not enable
# things like line editing in dash, so its interactive mode is very bare.
################################################################################

CROS_X86_RDEPEND="
	dptf? ( virtual/dptf )
	intel_lpe? ( virtual/lpe-support )
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
"

# Anything behind a USE flag belongs in the main RDEPEND list above.
# New packages usually should be behind a USE flag.
CROS_RDEPEND="${CROS_RDEPEND}
	app-arch/tar
	app-editors/vim
	app-shells/bash
	chromeos-base/common-assets
	chromeos-base/chromeos-imageburner
	chromeos-base/crosh
	chromeos-base/crosh-extension
	chromeos-base/inputcontrol
	chromeos-base/mtpd
	chromeos-base/permission_broker
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	chromeos-base/vpd
	net-wireless/crda
	sys-apps/dbus
	sys-apps/flashrom
	sys-apps/iproute2
	sys-apps/rootdev
	!systemd? ( sys-apps/upstart )
	sys-fs/e2fsprogs
	virtual/assets
	virtual/cheets
	virtual/udev
"

RDEPEND+="!cros_embedded? ( ${CROS_RDEPEND} )"

