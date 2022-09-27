# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libbrillo .gn"

PLATFORM_SUBDIR="libbrillo"

# platform.eclass automatically add dependency to libbrillo by default,
# but this package should not have the dependency.
WANT_LIBBRILLO="no"

inherit cros-workon platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/libbrillo/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="cros_host +dbus +device_mapper fuzzer -lvm_stateful_partition +udev"

COMMON_DEPEND="
	chromeos-base/minijail:=
	chromeos-base/vboot_reference:=
	dbus? ( dev-libs/dbus-glib:= )
	dev-libs/openssl:=
	dev-libs/protobuf:=
	net-libs/grpc:=
	net-misc/curl:=
	sys-apps/rootdev:=
	device_mapper? ( sys-fs/lvm2:=[thin] )
	lvm_stateful_partition? ( sys-fs/lvm2:= )
	udev? ( virtual/libudev )
"
RDEPEND="
	${COMMON_DEPEND}
	!cros_host? ( chromeos-base/libchromeos-use-flags )
	chromeos-base/chromeos-ca-certificates
	!chromeos-base/libchromeos
"
DEPEND="
	${COMMON_DEPEND}
	>=chromeos-base/protofiles-0.0.45:=
	dbus? ( chromeos-base/system_api:=[fuzzer?] )
	dev-libs/modp_b64:=
"

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	dolib.so "${OUT}"/lib/lib{brillo,installattributes,policy}*.so
	dolib.a "${OUT}"/libbrillo*.a
	# Install libbrillo with and without version number as a temporary
	# measure.
	doins "${OUT}"/obj/libbrillo/libbrillo*.pc

	# Install all the header files from libbrillo/brillo/*.h into
	# /usr/include/brillo (recursively, with sub-directories).
	local dir
	while read -d $'\0' -r dir; do
		insinto "/usr/include/${dir}"
		doins "${dir}"/*.h
	done < <(find brillo -type d -print0)

	insinto /usr/include/policy
	doins policy/*.h
	insinto /usr/include/install_attributes
	doins install_attributes/libinstallattributes.h

	# fuzzer_component_id is unknown/unlisted
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/libbrillo_data_encoding_fuzzer
	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/libbrillo_dbus_data_serialization_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/libbrillo_http_form_data_fuzzer
}

platform_pkg_test() {
	local gtest_filter_qemu="-*DeathTest*"
	platform_test "run" "${OUT}/libbrillo_tests" "" "" "${gtest_filter_qemu}"
	platform_test "run" "${OUT}/libinstallattributes_tests"
	platform_test "run" "${OUT}/libpolicy_tests"
	platform_test "run" "${OUT}/libbrillo-grpc_tests"
}
