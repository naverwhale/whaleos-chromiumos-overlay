# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_COMMIT="3a01873e59ec25ecb10d1b07ff9816e69f3bbfee"
CROS_WORKON_TREE="8ce164efd78fcb4a68e898d8c92c7579657a49b1"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages that are needed inside the Chromium OS test image;
Note: test images are a superset of dev images."
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os-test.
IUSE="
	arc-camera3
	biod
	-chromeless_tests
	cheets
	chromeless_tty
	cr50_onboard
	+cras
	cros_ec
	cros_embedded
	dlc
	hammerd
	iioservice
	ml_service
	hps
	nnapi
	ondevice_document_scanner
	opengl
	opengles
	p2p
	+perfetto
	python_targets_python2_7
	scanner
	+shill
	+tpm
	tpm2
	unibuild
	vaapi
	vulkan
	wifi_hostap_test
	wifi_testbed_ap
	+wired_8021x
"

# Packages required to support autotest images.  Dependencies here
# are for packages that must be present on a local device and that
# are not downloaded by the autotest server.  This includes both
# packages relied on by the server, as well as packages relied on by
# specific tests.
#
# This package is not meant to capture tools useful for test debug;
# use the chromeos-dev package for that purpose.
#
# Note that some packages used by autotest are actually built by the
# autotest package and downloaded by the server, regardless of
# whether the package is present on the target device; those
# packages aren't listed here.
#
# Developers should be aware that packages installed by this ebuild
# are rooted in /usr/local.  This means that libraries are installed
# in /usr/local/lib, executables in /usr/local/bin, etc.
#
# TODO(jrbarnette):  It's not known definitively that the list
# below contains no unneeded dependencies.  More work is needed to
# determine for sure that every package listed is actually used.


################################################################################
#
# CROS_COMMON_* : Dependencies common to all CrOS flavors (embedded, regular)
#
################################################################################

CROS_COMMON_RDEPEND="
	tpm? (
		app-crypt/tpm-tools
		chromeos-base/hwsec-test-utils
		chromeos-base/tpm_softclear_utils
	)
	!tpm2? (
		app-crypt/tpm-tools
		app-crypt/trousers
	)
	tpm2? (
		app-crypt/tpm2-abrmd
		app-crypt/tpm2-tss-engine
		app-crypt/tpm2-totp
		app-crypt/tpm2-tss
		app-crypt/tpm2-tools
		chromeos-base/hwsec-test-utils
		chromeos-base/tpm_softclear_utils
	)
	chromeos-base/chromeos-test-root
	chromeos-base/ec-utils
	chromeos-base/ec-utils-test
	chromeos-base/factory-deps
	biod? (
		virtual/chromeos-fpmcu-test
		chromeos-base/chromeos-fpmcu-unittests
	)
	hammerd? ( chromeos-base/hammerd-test-utils )
	iioservice? ( chromeos-base/iioservice_simpleclient )
	scanner? (
		chromeos-base/lorgnette_cli
		chromeos-base/lorgnette-wwcb-tests
		chromeos-base/sane-backends-test
	)
	ml_service? ( chromeos-base/ml-cmdline )
	hps? ( chromeos-base/hps-tool )
	nnapi? (
		chromeos-base/aosp-frameworks-ml-nn-vts
		chromeos-base/ml-test-assets
	)
	ondevice_document_scanner? (
		media-libs/cros-camera-document-scanning-test
	)
	chromeos-base/recover-duts
	chromeos-base/tast-local-test-runner
	chromeos-base/tast-local-tests
	chromeos-base/tast-use-flags
	chromeos-base/verity
	chromeos-base/vpd
	cros_ec? ( chromeos-base/ec-devutils )
	!chromeless_tty? (
		!chromeless_tests? (
			>=dev-cpp/gflags-2.0
		)
	)
	wifi_testbed_ap? (
		dev-python/btsocket
	)
	python_targets_python2_7? ( dev-lang/python:2.7 )
	dev-lang/python:3.6
	dev-libs/opensc
	p2p? ( dev-python/dpkt )
	perfetto? (
		chromeos-base/perfetto
		chromeos-base/perfetto_simple_producer
	)
	cr50_onboard? ( dev-util/u2f-ref-code )
	net-misc/rsync
	sys-apps/memtester
	virtual/autotest-capability
	virtual/chromeos-bsp-test
"

# Packages needed by FAFT.
CROS_COMMON_RDEPEND+="
	sys-apps/hdparm
	sys-apps/mmc-utils
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, etc.)
#
################################################################################
CROS_X86_RDEPEND="
	app-benchmarks/sysbench
	sys-apps/pciutils
	sys-power/iasl
	vaapi? ( media-gfx/vadumpcaps media-video/libva-utils )
	x11-misc/read-edid
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
"

CROS_RDEPEND="${CROS_RDEPEND}
	app-admin/sudo
	app-arch/gzip
	app-arch/tar
	app-benchmarks/blktests
	app-benchmarks/blogbench
	app-benchmarks/lmbench
	app-benchmarks/microbenchmarks
	app-benchmarks/pjdfstest
	app-benchmarks/xfstests
	app-misc/ckermit
	opengles? ( app-misc/eglinfo )
	app-misc/tmux
	app-misc/utouch-evemu
	app-mobilephone/dfu-util
	chromeos-base/autotest-client
	cras? (
		chromeos-base/audiotest
		media-sound/cras_bench
	)
	chromeos-base/avtest_label_detect
	chromeos-base/chrome-binary-tests
	chromeos-base/cros-camera-tool
	chromeos-base/cros-config-test
	!chromeless_tty? ( !chromeless_tests? ( chromeos-base/drm-tests ) )
	chromeos-base/factory-mini
	chromeos-base/glbench
	chromeos-base/graphics-utils-python
	chromeos-base/libvda-gpu-tests
	chromeos-base/modem-diagnostics
	chromeos-base/policy_utils
	chromeos-base/protofiles
	chromeos-base/pywalt
	!chromeless_tty? ( chromeos-base/screen-capture-utils )
	chromeos-base/secure-wipe
	shill? (
		chromeos-base/shill-test-scripts
		wired_8021x? ( net-wireless/hostapd )
	)
	!chromeless_tests? ( chromeos-base/telemetry )
	chromeos-base/toolchain-tests
	vulkan? (
		chromeos-base/vkbench
	)
	dev-embedded/dfu-programmer
	dev-go/syzkaller
	dev-libs/re2
	dev-python/protobuf-python
	dev-python/btsocket
	dev-python/contextlib2
	dev-python/dbus-python
	dev-python/dpkt
	dev-python/httplib2
	dev-python/jsonrpclib
	dev-python/mkvparse
	dev-python/netifaces
	dev-python/pygobject
	dev-python/pyserial
	dev-python/pytest
	dev-python/python-evdev
	dev-python/python-uinput
	dev-python/pyudev
	dev-python/pyxattr
	dev-python/pyyaml
	dev-python/selenium
	dev-python/setproctitle
	dev-python/setuptools
	dev-python/ws4py
	!chromeless_tty? ( !chromeless_tests? ( dev-util/apitrace ) )
	dev-util/stressapptest
	dev-util/trace-cmd
	dlc? ( sys-fs/squashfs-tools )
	games-util/joystick
	media-gfx/imagemagick[jpeg,png,svg,tiff]
	media-gfx/perceptualdiff
	media-gfx/zbar
	arc-camera3? ( media-libs/cros-camera-libcamera_connector_test )
	arc-camera3? ( media-libs/cros-camera-libjea_test )
	arc-camera3? ( media-libs/cros-camera-test )
	media-libs/cros-camera-v4l2_test
	media-libs/libexif
	media-libs/libvpx
	media-libs/opencv
	media-libs/openh264
	!chromeless_tty? ( !chromeless_tests? (
		media-gfx/deqp
		media-gfx/deqp-runner
	) )
	media-libs/tiff
	opengles? ( media-libs/waffle )
	opengl? ( media-libs/waffle )
	media-sound/sox
	net-analyzer/netperf
	net-dialup/minicom
	net-dns/dnsmasq
	net-misc/dhcp
	net-misc/iperf:2
	net-misc/iputils
	net-misc/openssh
	net-misc/radvd
	net-proxy/tinyproxy
	wifi_hostap_test? ( net-wireless/hostap-test )
	sci-geosciences/gpsd
	sys-apps/coreutils
	sys-apps/dtc
	sys-apps/ethtool
	sys-apps/file
	sys-apps/findutils
	sys-apps/kbd
	sys-apps/shadow
	sys-devel/binutils
	sys-process/iotop
	sys-process/procps
	sys-process/psmisc
	sys-process/time
	x11-libs/libdrm
	"

################################################################################
# Assemble the final RDEPEND and DEPEND variables for portage
################################################################################
RDEPEND="${CROS_COMMON_RDEPEND}
	!cros_embedded? ( ${CROS_RDEPEND} )
"
