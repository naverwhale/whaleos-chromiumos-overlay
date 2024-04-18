# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk metrics net-base patchpanel shill/net .gn"

PLATFORM_SUBDIR="patchpanel"
# Do not run test in parallel for patchpanel by default. There doesn't seem to
# be too much benefit on speed now but affects the debugging experience.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon libchrome platform tmpfiles user

DESCRIPTION="Patchpanel network connectivity management daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/patchpanel/"
LICENSE="BSD-Google"
KEYWORDS="~*"

# These USE flags are used in patchpanel/BUILD.gn
IUSE="fuzzer arcvm kvm_host"

COMMON_DEPEND="
	chromeos-base/metrics:=
	chromeos-base/minijail:=
	chromeos-base/net-base:=
	chromeos-base/shill-net:=
	chromeos-base/system_api:=[fuzzer?]
	dev-libs/protobuf:=
	dev-libs/re2:=
	net-libs/libnetfilter_conntrack
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/shill
	kvm_host? ( chromeos-base/vm_host_tools:= )
	net-dns/dnsmasq
	net-firewall/conntrack-tools
	net-firewall/iptables
	net-misc/bridge-utils
	net-misc/radvd
	net-proxy/tayga
	sys-apps/iproute2
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/session_manager-client:=
	chromeos-base/shill-client:=
	chromeos-base/system_api:=[fuzzer?]
	chromeos-base/vboot_reference:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
	dev-libs/protobuf
"

patchpanel_header() {
	doins "$1"
	sed -i '/.pb.h/! s:patchpanel/:chromeos/patchpanel/:g' \
		"${D}/usr/include/chromeos/patchpanel/$1" || die
}

src_install() {
	platform_src_install

	"${S}"/preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libpatchpanel-util.pc

	insinto /usr/include/chromeos/patchpanel/
	patchpanel_header address_manager.h
	patchpanel_header mac_address_generator.h
	patchpanel_header message_dispatcher.h
	patchpanel_header mock_message_dispatcher.h
	patchpanel_header net_util.h
	patchpanel_header socket.h
	patchpanel_header socket_forwarder.h
	patchpanel_header subnet.h
	patchpanel_header subnet_pool.h

	insinto /usr/include/chromeos/patchpanel/dns
	patchpanel_header dns/dns_protocol.h
	patchpanel_header dns/dns_query.h
	patchpanel_header dns/dns_response.h
	patchpanel_header dns/io_buffer.h

	dotmpfiles tmpfiles.d/*.conf

	local fuzzer
	for fuzzer in "${OUT}"/*_fuzzer; do
		local fuzzer_component_id="156085"
		platform_fuzzer_install "${S}"/OWNERS "${fuzzer}" \
			--comp "${fuzzer_component_id}"
	done
}

pkg_preinst() {
	# Service account used for privilege separation.
	enewuser patchpaneld
	enewgroup patchpaneld
}

platform_pkg_test() {
	platform test_all
}
