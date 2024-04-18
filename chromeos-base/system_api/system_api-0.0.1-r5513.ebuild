# Copyright 2011 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="28855525b6c452b8822c99272354f0aece775a5d"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "ce84e9b1511f8a8a2389efe0a3a5c45b49fb817d" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_GO_PACKAGES=(
	"chromiumos/system_api/..."
)

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk system_api .gn"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="system_api"
WANT_LIBBRILLO="no"

inherit cros-fuzzer cros-go cros-workon platform

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/system_api/"
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="
	dev-libs/protobuf:=
	cros_host? ( net-libs/grpc:= )
"

DEPEND="${RDEPEND}
	dev-go/protobuf:=
	dev-go/protobuf-legacy-api:=
"

BDEPEND="
	dev-go/protobuf-legacy-api
	dev-libs/protobuf
"

src_unpack() {
	platform_src_unpack
	CROS_GO_WORKSPACE="${OUT}/gen/go"
}

src_install() {
	platform_src_install

	find "${D}"/usr/include/ \
		'(' -name OWNERS -o -name DIR_METADATA -o -name '*.md' ')' \
		-delete || die

	# Install the dbus-constants.h files in the respective daemons' client library
	# include directory. Users will need to include the corresponding client
	# library to access these files.
	local dir dirs=(
		anomaly_detector
		attestation
		biod
		chunneld
		cros-disks
		cros_healthd
		cryptohome
		debugd
		discod
		dlcservice
		kerberos
		login_manager
		lorgnette
		oobe_config
		runtime_probe
		pciguard
		permission_broker
		printscanmgr
		power_manager
		rgbkbd
		rmad
		shadercached
		shill
		smbprovider
		tpm_manager
		u2f
		update_engine
		wilco_dtc_supportd
	)
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"-client/"${dir}"
		doins dbus/"${dir}"/dbus-constants.h
	done

	cros-go_src_install
}
