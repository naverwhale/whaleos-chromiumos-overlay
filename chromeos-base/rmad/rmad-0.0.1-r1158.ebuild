# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "0e36d9654da50d77f6c5cb72209cc649e3f5cade" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "51a1c425e169ed912ef77b70361becbd07995916" "04af2f1005707115b755acd5276795815a335d6b" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "05a052ec9a484e721478c7bb3e5e8e76c4ddc016" "acad9cc02bb1a1010c4cd02a5b726f6b7a3efe92" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chromeos-config hardware_verifier libec libmems libsegmentation metrics mojo_service_manager rmad .gn"

# Tests use /dev/loop*.
PLATFORM_HOST_DEV_TEST="yes"
PLATFORM_SUBDIR="rmad"

inherit cros-workon cros-unibuild platform tmpfiles user

DESCRIPTION="ChromeOS RMA daemon."
HOMEPAGE=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cr50_onboard ti50_onboard test"

COMMON_DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/iioservice:=
	chromeos-base/libec:=
	chromeos-base/libmems:=[test?]
	chromeos-base/libsegmentation:=[test?]
	chromeos-base/metrics:=
	chromeos-base/minijail:=
	chromeos-base/mojo_service_manager:=
	dev-libs/openssl:0=
	dev-libs/protobuf:=
	dev-libs/re2:=
	sys-apps/util-linux:=
	virtual/libusb:=
"

RDEPEND="
	${COMMON_DEPEND}
	cr50_onboard? ( chromeos-base/chromeos-cr50 )
	ti50_onboard? ( chromeos-base/chromeos-ti50 )
	chromeos-base/croslog
	chromeos-base/hardware_verifier
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/cryptohome-client:=
	chromeos-base/libiioservice_ipc:=
	chromeos-base/runtime_probe-client:=
	chromeos-base/shill-client:=
	chromeos-base/system_api:=
	chromeos-base/tpm_manager-client:=
"

BDEPEND="
	chromeos-base/minijail
	dev-libs/protobuf
"

pkg_preinst() {
	# Create user and group for RMA.
	enewuser "rmad"
	enewgroup "rmad"
}

src_install() {
	platform_src_install

	dotmpfiles tmpfiles.d/*.conf
}

platform_pkg_test() {
	local gtest_filter_user_tests="-*RunAsRoot*"
	local gtest_filter_root_tests="*RunAsRoot*-"

	platform_test "run" "${OUT}/rmad_test" "0" "${gtest_filter_user_tests}"
	platform_test "run" "${OUT}/rmad_test" "1" "${gtest_filter_root_tests}"
}
