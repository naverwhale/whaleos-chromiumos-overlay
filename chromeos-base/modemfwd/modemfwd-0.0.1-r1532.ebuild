# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "3b3d420962a578dc56f77d75ed95345fcb0f25b7" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk chromeos-config metrics modemfwd .gn"

PLATFORM_SUBDIR="modemfwd"

inherit cros-workon platform tmpfiles udev user

DESCRIPTION="Modem firmware updater daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/modemfwd"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE="fuzzer"

COMMON_DEPEND="
	app-arch/xz-utils:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/dlcservice-client:=
	chromeos-base/metrics:=
	dev-libs/protobuf:=
	net-misc/modemmanager-next:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/minijail:=
	chromeos-base/shill-client:=
	chromeos-base/system_api:=[fuzzer?]
	dev-libs/re2:=
	fuzzer? ( dev-libs/libprotobuf-mutator:= )
"

src_install() {
	platform_src_install

	dotmpfiles tmpfiles.d/*.conf

	# udev scripts and rules.
	exeinto "$(get_udevdir)"
	doexe udev/*.sh

	local fuzzer_component_id="167157"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/firmware_manifest_v2_fuzzer \
		--comp "${fuzzer_component_id}"

	insinto /usr/share/policy
	newins "seccomp/modemfwd-mbimcli-seccomp-${ARCH}.policy" modemfwd-mbimcli-seccomp.policy
}

platform_pkg_test() {
	platform test_all
}
