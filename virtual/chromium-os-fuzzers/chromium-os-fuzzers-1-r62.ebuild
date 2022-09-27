# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_COMMIT="3a01873e59ec25ecb10d1b07ff9816e69f3bbfee"
CROS_WORKON_TREE="8ce164efd78fcb4a68e898d8c92c7579657a49b1"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

DESCRIPTION="List of packages that should be fuzzed"
HOMEPAGE="https://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE="asan msan"

RDEPEND="
	chromeos-base/arc-adbd[fuzzer]
	asan? ( chromeos-base/arc-keymaster[fuzzer] )
	chromeos-base/arc-obb-mounter[fuzzer]
	chromeos-base/arc-setup[fuzzer]
	chromeos-base/authpolicy[fuzzer]
	chromeos-base/biod[fuzzer]
	chromeos-base/chaps[fuzzer]
	chromeos-base/chromeos-ec[fuzzer]
	chromeos-base/chromeos-login[fuzzer]
	chromeos-base/crash-reporter[fuzzer]
	chromeos-base/cros-disks[fuzzer]
	chromeos-base/crosdns[fuzzer]
	chromeos-base/cryptohome[fuzzer]
	chromeos-base/cups-fuzz[fuzzer]
	chromeos-base/diagnostics[fuzzer]
	chromeos-base/dlcservice[fuzzer]
	chromeos-base/dns-proxy[fuzzer]
	chromeos-base/foomatic_shell[fuzzer]
	chromeos-base/ghostscript-fuzz[fuzzer]
	chromeos-base/hammerd[fuzzer]
	chromeos-base/imageloader[fuzzer]
	chromeos-base/kerberos[fuzzer]
	chromeos-base/libbrillo[fuzzer]
	chromeos-base/libipp[fuzzer]
	asan? ( chromeos-base/libvda[fuzzer] )
	chromeos-base/metrics[fuzzer]
	chromeos-base/ml[fuzzer]
	chromeos-base/modemfwd[fuzzer]
	chromeos-base/p2p[fuzzer]
	chromeos-base/patchpanel[fuzzer]
	chromeos-base/patchpanel-client[fuzzer]
	chromeos-base/permission_broker[fuzzer]
	chromeos-base/power_manager[fuzzer]
	chromeos-base/runtime_probe[fuzzer]
	>=chromeos-base/shill-0.0.1-r2205[fuzzer]
	chromeos-base/smbprovider[fuzzer]
	chromeos-base/sommelier[fuzzer]
	chromeos-base/system-proxy[fuzzer]
	chromeos-base/trunks[fuzzer]
	chromeos-base/u2fd[fuzzer]
	chromeos-base/update_engine[fuzzer]
	chromeos-base/usb_bouncer[fuzzer]
	chromeos-base/vboot_reference[fuzzer]
	chromeos-base/vm_guest_tools[fuzzer]
	chromeos-base/vpn-manager[fuzzer]
	asan? ( chromeos-base/vm_host_tools[fuzzer] )
	dev-libs/modp_b64[fuzzer]
	asan? ( dev-rust/p9[fuzzer] )
	dev-util/bsdiff[fuzzer]
	dev-util/puffin[fuzzer]
	media-gfx/sane-airscan[fuzzer]
	media-libs/virglrenderer[fuzzer]
	media-sound/adhd[fuzzer]
	net-dns/avahi[fuzzer]
	net-wireless/bluez[fuzzer]
	net-wireless/wpa_supplicant-cros[fuzzer]
"
