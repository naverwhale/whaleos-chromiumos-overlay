# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "433938c209efa6b28167ed132ea135f2fe1af94a" "1f0e98c60804e0854326f3b20e6008fb5cb928ea" "51a1c425e169ed912ef77b70361becbd07995916" "4590aa4213893b0df46f17778b4daa4d999277ce" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Remove libmems from this list.
CROS_WORKON_SUBTREE="common-mk chromeos-config iioservice mems_setup libmems libsar .gn"

PLATFORM_SUBDIR="mems_setup"

inherit cros-workon cros-unibuild platform udev

DESCRIPTION="MEMS Setup for Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/mems_setup"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="fuzzer iioservice_proximity test"

COMMON_DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/libmems:=[test?]
	chromeos-base/libsar:=[test?]
	net-libs/libiio:=
	dev-libs/re2:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/system_api:="

src_install() {
	udev_dorules 99-mems_setup.rules
	platform_src_install

	# Install fuzzers
	local fuzzer_component_id="811602"
	insinto /usr/libexec/fuzzers
	for fuzzer in "${OUT}"/*_fuzzer; do
		platform_fuzzer_install "${S}"/OWNERS "${fuzzer}" \
				--comp "${fuzzer_component_id}"
	done
}

platform_pkg_test() {
	platform test_all
}
