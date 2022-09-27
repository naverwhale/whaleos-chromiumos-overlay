# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="84bc47b12e897c21f2240895e67d61777631e541"
CROS_WORKON_TREE="cf4004054094ce8665512d92d5a19acde9e68cd4"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME="third_party/autotest/files"

inherit cros-workon autotest

DESCRIPTION="Autotest server tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/autotest/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Enable autotest by default.
IUSE="android-container android-container-pi android-vm-rvc +autotest biod +cellular +cheets_user cheets_user_64 cheets_userdebug_64 -chromeless_tests -chromeless_tty cros_p2p debugd dlc_test has-kernelnext is-kernelnext -moblab +power_management +readahead +tpm tpm2"
REQUIRED_USE="?? ( has-kernelnext is-kernelnext )"

RDEPEND=""
DEPEND="${RDEPEND}
	!<chromeos-base/autotest-0.0.2
"

SERVER_IUSE_TESTS="
	+tests_android_ACTS
	+tests_android_EasySetup
	+tests_audio_AudioAfterReboot
	+tests_audio_AudioAfterSuspend
	+tests_audio_AudioArtifacts
	+tests_audio_AudioBasicAssistant
	+tests_audio_AudioBasicBluetoothPlayback
	+tests_audio_AudioBasicBluetoothPlaybackRecord
	+tests_audio_AudioBasicBluetoothRecord
	+tests_audio_AudioBasicExternalMicrophone
	+tests_audio_AudioBasicHDMI
	+tests_audio_AudioBasicHeadphone
	+tests_audio_AudioBasicHotwording
	+tests_audio_AudioBasicInternalMicrophone
	+tests_audio_AudioBasicInternalSpeaker
	+tests_audio_AudioBasicUSBPlayback
	+tests_audio_AudioBasicUSBPlaybackRecord
	+tests_audio_AudioBasicUSBRecord
	+tests_audio_AudioBluetoothConnectionStability
	+tests_audio_AudioNodeSwitch
	+tests_audio_AudioNoiseCancellation
	+tests_audio_AudioPinnedStream
	+tests_audio_AudioQualityAfterSuspend
	+tests_audio_AudioTestAssumptionCheck
	+tests_audio_AudioVolume
	+tests_audio_AudioWebRTCLoopback
	+tests_audio_InternalCardNodes
	+tests_audio_LeftRightInternalSpeaker
	+tests_audio_MediaBasicVerification
	+tests_audio_PowerConsumption
	+tests_audiovideo_AVSync
	+tests_autoupdate_Basic
	+tests_autoupdate_CatchBadSignatures
	+tests_autoupdate_Cellular
	+tests_autoupdate_ConsecutiveUpdatesBeforeReboot
	+tests_autoupdate_DataPreserved
	+tests_autoupdate_ForcedOOBEUpdate
	+tests_autoupdate_FromUI
	+tests_autoupdate_Interruptions
	+tests_autoupdate_NonBlockingOOBEUpdate
	+tests_autoupdate_OmahaResponse
	+tests_autoupdate_P2P
	+tests_autoupdate_Periodic
	+tests_autoupdate_RejectDuplicateUpdate
	+tests_autoupdate_Rollback
	dlc_test? ( +tests_autoupdate_WithDLC )
	cellular? ( +tests_cellular_StaleModemReboot )
	android-container-pi? (
		cheets_user? (
			+tests_cheets_CTS_Instant
			+tests_cheets_CTS_P
		)
		cheets_user_64? (
			+tests_cheets_CTS_Instant
			+tests_cheets_CTS_P
		)
	)
	android-vm-rvc? (
		cheets_user_64? (
			+tests_cheets_CTS_R
		)
		cheets_userdebug_64? (
			+tests_cheets_VTS_R
		)
	)
	+tests_cellular_Callbox_AssertCellularData
	+tests_cellular_Callbox_AssertSMS
	+tests_cheets_LabDependencies
	debugd? ( +tests_debugd_DevTools )
	+tests_crosperf_Wrapper
	+tests_display_EdidStress
	+tests_display_HDCPScreen
	+tests_display_HotPlugAtBoot
	+tests_display_HotPlugAtSuspend
	+tests_display_HotPlugNoisy
	+tests_display_LidCloseOpen
	+tests_display_NoEdid
	+tests_display_Resolution
	+tests_display_ResolutionList
	+tests_display_ServerChameleonConnection
	+tests_display_SuspendStress
	+tests_display_SwitchMode
	+tests_enterprise_ClearTPM
	+tests_enterprise_KioskEnrollmentServer
	+tests_enterprise_LongevityTrackerServer
	+tests_enterprise_OnlineDemoMode
	+tests_factory_Basic
	+tests_firmware_Bmpblk
	+tests_firmware_CgptStress
	+tests_firmware_ClearTPMOwnerAndReset
	+tests_firmware_ConsecutiveBoot
	+tests_firmware_ConsecutiveBootPowerButton
	+tests_firmware_ConsecutiveLidSwitch
	+tests_firmware_CorruptBothFwBodyAB
	+tests_firmware_CorruptBothFwSigAB
	+tests_firmware_CorruptBothKernelAB
	+tests_firmware_CorruptFwBodyA
	+tests_firmware_CorruptFwBodyB
	+tests_firmware_CorruptFwSigA
	+tests_firmware_CorruptFwSigB
	+tests_firmware_CorruptKernelA
	+tests_firmware_CorruptKernelB
	+tests_firmware_CorruptRecoveryCache
	+tests_firmware_Cr50BID
	+tests_firmware_Cr50CCDServoCap
	+tests_firmware_Cr50CCDUartStress
	+tests_firmware_Cr50CheckCap
	+tests_firmware_Cr50ConsoleCommands
	+tests_firmware_Cr50DeepSleepStress
	+tests_firmware_Cr50DeferredECReset
	+tests_firmware_Cr50DeviceState
	+tests_firmware_Cr50DevMode
	+tests_firmware_Cr50ECReset
	+tests_firmware_Cr50FactoryResetVC
	+tests_firmware_Cr50CCDFirmwareUpdate
	+tests_firmware_Cr50GetName
	+tests_firmware_Cr50InvalidateRW
	+tests_firmware_Cr50Keygen
	+tests_firmware_Cr50Open
	+tests_firmware_Cr50OpenWhileAPOff
	+tests_firmware_Cr50PartialBoardId
	+tests_firmware_Cr50Password
	+tests_firmware_Cr50PinWeaverServer
	+tests_firmware_Cr50RddG3
	+tests_firmware_Cr50RejectUpdate
	+tests_firmware_Cr50RMAOpen
	+tests_firmware_Cr50SetBoardId
	+tests_firmware_Cr50ShortECC
	+tests_firmware_Cr50Testlab
	+tests_firmware_Cr50TpmManufactured
	+tests_firmware_Cr50TpmMode
	+tests_firmware_Cr50U2fCommands
	+tests_firmware_Cr50Unlock
	+tests_firmware_Cr50Update
	+tests_firmware_Cr50UpdateScriptStress
	+tests_firmware_Cr50USB
	+tests_firmware_Cr50VerifyEK
	+tests_firmware_Cr50WilcoEcrst
	+tests_firmware_Cr50WilcoRmaFactoryMode
	+tests_firmware_Cr50WPG3
	+tests_firmware_CsmeFwUpdate
	+tests_firmware_DevBootUSB
	+tests_firmware_DevDefaultBoot
	+tests_firmware_DevMode
	+tests_firmware_DevModeStress
	+tests_firmware_DevScreenTimeout
	+tests_firmware_ECBattery
	+tests_firmware_ECBootTime
	+tests_firmware_ECCbiEeprom
	+tests_firmware_ECCharging
	+tests_firmware_ECChargingState
	+tests_firmware_ECHash
	+tests_firmware_ECKeyboard
	+tests_firmware_ECKeyboardReboot
	+tests_firmware_ECLidShutdown
	+tests_firmware_ECLidSwitch
	+tests_firmware_ECPowerButton
	+tests_firmware_ECPowerG3
	+tests_firmware_ECSharedMem
	+tests_firmware_ECSystemLocked
	+tests_firmware_ECThermal
	+tests_firmware_ECUpdateId
	+tests_firmware_ECUsbPorts
	+tests_firmware_ECWakeFromULP
	+tests_firmware_ECWakeSource
	+tests_firmware_ECWatchdog
	+tests_firmware_EmmcWriteLoad
	+tests_firmware_EventLog
	+tests_firmware_FAFTPrepare
	+tests_firmware_FAFTModeTransitions
	+tests_firmware_FAFTRPC
	+tests_firmware_FAFTSetup
	biod? (
		+tests_firmware_Fingerprint
		+tests_firmware_FingerprintCrosConfig
		+tests_firmware_FingerprintSigner
	)
	+tests_firmware_FMap
	+tests_firmware_FWMPDisableCCD
	+tests_firmware_FwScreenCloseLid
	+tests_firmware_FwScreenPressPower
	+tests_firmware_FWupdateWP
	+tests_firmware_FWtries
	+tests_firmware_FWupdateThenSleep
	+tests_firmware_FWupdateWP
	+tests_firmware_IntegratedU2F
	+tests_firmware_InvalidUSB
	+tests_firmware_LegacyRecovery
	+tests_firmware_MenuModeTransition
	+tests_firmware_MiniDiag
	+tests_firmware_Mosys
	+tests_firmware_PDConnect
	+tests_firmware_PDDataSwap
	+tests_firmware_PDPowerSwap
	+tests_firmware_PDProtocol
	+tests_firmware_PDResetHard
	+tests_firmware_PDResetSoft
	+tests_firmware_PDTrySrc
	+tests_firmware_PDVbusRequest
	+tests_firmware_RecoveryButton
	+tests_firmware_RecoveryCacheBootKeys
	+tests_firmware_RollbackFirmware
	+tests_firmware_RollbackKernel
	+tests_firmware_SelfSignedBoot
	+tests_firmware_SetSerialNumber
	+tests_firmware_SoftwareSync
	+tests_firmware_StandbyPowerConsumption
	+tests_firmware_SysfsVPD
	+tests_firmware_TPMNotCorruptedDevMode
	tpm? ( +tests_firmware_TPMExtend )
	tpm? ( +tests_firmware_TPMVersionCheck )
	tpm? ( +tests_firmware_TPMKernelVersion )
	tpm2? ( +tests_firmware_TPMExtend )
	tpm2? ( +tests_firmware_TPMVersionCheck )
	tpm2? ( +tests_firmware_TPMKernelVersion )
	+tests_firmware_TryFwB
	+tests_firmware_TypeCCharging
	+tests_firmware_TypeCProbeUSB3
	+tests_firmware_UpdateFirmwareDataKeyVersion
	+tests_firmware_UpdateFirmwareVersion
	+tests_firmware_UpdateKernelDataKeyVersion
	+tests_firmware_UpdateKernelSubkeyVersion
	+tests_firmware_UpdateKernelVersion
	+tests_firmware_UpdaterModes
	+tests_firmware_UserRequestRecovery
	+tests_firmware_WilcoDiagnosticsMode
	+tests_firmware_WriteProtect
	+tests_firmware_WriteProtectFunc
	+tests_graphics_MultipleDisplays
	+tests_graphics_PowerConsumption
	+tests_hardware_DiskFirmwareUpgrade
	+tests_hardware_MemoryIntegrity
	+tests_hardware_StorageQual
	+tests_hardware_StorageQualBase
	+tests_hardware_StorageQualCheckSetup
	+tests_hardware_StorageQualSuspendStress
	+tests_hardware_StorageQualTrimStress
	+tests_hardware_StorageQualV2
	+tests_hardware_StorageStress
	+tests_infra_ServerPythonVersion
	+tests_infra_TLSExecDUTCommand
	+tests_kernel_EmptyLines
	+tests_kernel_ExternalUsbPeripheralsDetectionTest
	+tests_kernel_IdlePerf
	+tests_kernel_MemoryRamoop
	moblab? (
		+tests_moblab_RunSuite
		+tests_moblab_StorageQual
	)
	+tests_moblab_Setup
	cros_p2p? ( +tests_p2p_EndToEndTest )
	+tests_network_FirewallHolePunchServer
	+tests_platform_ActivateDate
	+tests_platform_BootDevice
	+tests_platform_BootLockboxServer
	+tests_platform_BootPerfServer
	+tests_platform_CompromisedStatefulPartition
	+tests_platform_CorruptRootfs
	+tests_platform_CrashStateful
	+tests_platform_ExternalUsbPeripherals
	+tests_platform_FetchCloudConfig
	+tests_platform_FlashErasers
	+tests_platform_Flashrom
	+tests_platform_HWwatchdog
	+tests_platform_InitLoginPerfServer
	+tests_platform_InstallTestImage
	+tests_platform_InternalDisplay
	+tests_platform_KernelErrorPaths
	+tests_platform_MTBF
	power_management? (
		+tests_platform_PowerStatusStress
		+tests_power_DeferForFlashrom
		+tests_power_WakeSources
	)
	+tests_platform_Powerwash
	+tests_platform_RotationFps
	+tests_platform_ServoPowerStateController
	+tests_platform_StageAndRecover
	+tests_platform_SyncCrash
	readahead? ( +tests_platform_UReadAheadServer )
	+tests_platform_Vpd
	+tests_policy_AUServer
	+tests_policy_DeviceChargingServer
	+tests_policy_DeviceServer
	+tests_policy_ExternalStorageServer
	+tests_policy_GlobalNetworkSettingsServer
	+tests_policy_WiFiAutoconnectServer
	+tests_policy_WiFiPrecedenceServer
	+tests_policy_WiFiTypesServer
	+tests_policy_WilcoServerDeviceDockMacAddressSource
	+tests_policy_WilcoServerOnNonWilcoDevice
	+tests_policy_WilcoServerUSBPowershare
	+tests_power_BrightnessResetAfterReboot
	+tests_power_ChargeControlWrapper
	+tests_power_MeetCall
	+tests_power_Monitoring
	+tests_power_LW
	+tests_power_PowerlogWrapper
	+tests_power_RPMTest
	+tests_power_ServoChargeStress
	+tests_power_ServodWrapper
	+tests_provision_CheetsUpdate
	+tests_provision_Cr50TOT
	+tests_provision_Cr50Update
	+tests_provision_FactoryImage
	+tests_provision_FirmwareUpdate
	+tests_provision_QuickProvision
	+tests_rlz_CheckPing
	+tests_sequences
	+tests_servo_LabControlVerification
	+tests_servo_LabstationVerification
	+tests_servo_USBMuxVerification
	+tests_servo_LogGrab
	+tests_servo_Verification
	+tests_servohost_Reboot
	+tests_stress_ClientTestReboot
	+tests_stress_EnrollmentRetainment
	+tests_stub_FailServer
	+tests_stub_PassServer
	+tests_stub_ServerToClientPass
	+tests_stub_SynchronousOffloadServer
"

IUSE_TESTS="${IUSE_TESTS}
	${SERVER_IUSE_TESTS}
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

INIT_FILE="__init__.py"

src_install() {
	# Make sure we install all |SERVER_IUSE_TESTS| first.
	autotest_src_install
	# Autotest depends on a few strategically placed INIT_FILEs to allow
	# importing python code. In particular we want to allow importing
	# server.site_tests.tast to be able to launch tast local tests.
	# This INIT_FILE exists in git, but needs to be installed and finally
	# packaged via chromite/lib/autotest_util.py into
	# autotest_server_package.tar.bz2 to be served by devservers.
	insinto "${AUTOTEST_BASE}/${AUTOTEST_SERVER_SITE_TESTS}"
	doins "${AUTOTEST_SERVER_SITE_TESTS}/${INIT_FILE}"
}
