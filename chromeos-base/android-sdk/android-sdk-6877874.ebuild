# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Android SDK"
HOMEPAGE="http://developer.android.com"

# NOTE: Due to possible licensing issues, only use AOSP SDK:
# https://ci.android.com/builds/branches/aosp-sdk-release/grid?
SRC_URI="https://ci.android.com/builds/submitted/${PV}/sdk/latest/android-sdk_${PV}_linux-x86.zip"

LICENSE="
	AOSP-SDK
	"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="strip"

DEPEND=""
# CTS P depends on Java 8 or 9. CTS R depends on Java 9 or later.
# Include both JDK8 and JDK11 in the chroot.
RDEPEND="
	<=virtual/jdk-9
	>=virtual/jdk-9
	>=dev-java/ant-core-1.6.5
	sys-libs/zlib"
BDEPEND=""

ANDROID_SDK_DIR="/opt/android-sdk"

S="${WORKDIR}"

src_install() {
	# NOTE: The two downloaded zips use "android-S" for their directories.
	# It seems that they take the name of the latest Android SDK at the
	# moment it was built, even if they were compiled from a different
	# branch. See build.prop: notice conflict between SDK version and name:
	# https://ci.android.com/builds/submitted/5303910/sdk/latest/view/build.prop

	# Zips to be installed:
	#  - Android SDK 30: both build-tools and platforms

	# License file for platforms and build-tools is in licenses/AOSP-SDK
	# TODO(ricardoq): Rename "android-S" to "android-30"
	insinto "${ANDROID_SDK_DIR}"
	doins -r ${PN}_${PV}_linux-x86/platforms
	insopts "-m0755"
	insinto "${ANDROID_SDK_DIR}/build-tools/android-S"
	doins ${PN}_${PV}_linux-x86/build-tools/android-S/aapt2
	doins ${PN}_${PV}_linux-x86/build-tools/android-S/apksigner
	doins ${PN}_${PV}_linux-x86/build-tools/android-S/d8
	doins -r ${PN}_${PV}_linux-x86/build-tools/android-S/lib
}
