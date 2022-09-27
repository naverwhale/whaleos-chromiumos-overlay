# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="2e047d239577285cb4706648ce9029e9c98ccebc"
CROS_WORKON_TREE="2bd0d5f238e77c48849cd1351e8f2921e005418f"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

inherit cros-workon autotest

DESCRIPTION="Autotest server tests for shill"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="-chromeless_tests +autotest -chromeless_tty"

SERVER_IUSE_TESTS="
	+tests_network_WiFi_APSupportedRates
	+tests_network_WiFi_AssocConfigPerformance
	+tests_network_WiFi_AttenuatedPerf
	+tests_network_WiFi_BeaconInterval
	+tests_network_WiFi_BgscanBackoff
	+tests_network_WiFi_BluetoothScanPerf
	+tests_network_WiFi_BluetoothStreamPerf
	+tests_network_WiFi_BSSTMReq
	+tests_network_WiFi_BT_AntennaCoex
	+tests_network_WiFi_ChannelHop
	+tests_network_WiFi_ChannelScanDwellTime
	+tests_network_WiFi_ChaosConfigFailure
	+tests_network_WiFi_ChaosConnectDisconnect
	+tests_network_WiFi_ChaosLongConnect
	!chromeless_tty (
		!chromeless_tests (
			+tests_cellular_ChromeEndToEnd
			+tests_network_WiFi_ChromeEndToEnd
			+tests_network_WiFi_RoamEndToEnd
			+tests_network_WiFi_RoamSuspendEndToEnd
		)
	)
	+tests_network_WiFi_CSA
	+tests_network_WiFi_DarkResumeActiveScans
	+tests_network_WiFi_DisableEnable
	+tests_network_WiFi_DisableRandomMACAddress
	+tests_network_WiFi_DisconnectReason
	+tests_network_WiFi_DTIMPeriod
	+tests_network_WiFi_FastReconnectInDarkResume
	+tests_network_WiFi_GTK
	+tests_network_WiFi_HiddenRemains
	+tests_network_WiFi_HiddenScan
	+tests_network_WiFi_LinkMonitorFailure
	+tests_network_WiFi_MalformedProbeResp
	+tests_network_WiFi_MultiAuth
	+tests_network_WiFi_OverlappingBSSScan
	+tests_network_WiFi_Perf
	+tests_network_WiFi_PMKSACaching
	+tests_network_WiFi_Prefer5Ghz
	+tests_network_WiFi_ProfileBasic
	+tests_network_WiFi_ProfileGUID
	+tests_network_WiFi_PTK
	+tests_network_WiFi_RandomMACAddress
	+tests_network_WiFi_Reassociate
	+tests_network_WiFi_ReconnectInDarkResume
	+tests_network_WiFi_Reset
	+tests_network_WiFi_Roam
	+tests_network_WiFi_RoamDbus
	+tests_network_WiFi_RoamFT
	+tests_network_WiFi_RoamSuspendTimeout
	+tests_network_WiFi_SecChange
	+tests_network_WiFi_SetOptionalDhcpProperties
	+tests_network_WiFi_SimpleConnect
	+tests_network_WiFi_SSIDSwitchBack
	+tests_network_WiFi_SuspendStress
	+tests_network_WiFi_StressTest
	+tests_network_WiFi_Throttle
	+tests_network_WiFi_UpdateRouter
	+tests_network_WiFi_VerifyRouter
	+tests_network_WiFi_VisibleScan
	+tests_network_WiFi_WakeOnDisconnect
	+tests_network_WiFi_WakeOnSSID
	+tests_network_WiFi_WakeOnWiFiThrottling
	+tests_network_WiFi_WoWLAN
	+tests_network_WiFi_WMM
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
