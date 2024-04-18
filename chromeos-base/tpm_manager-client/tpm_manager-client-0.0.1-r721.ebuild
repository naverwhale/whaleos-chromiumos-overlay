# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "1268480d08437246442187941fe41c4d00a5c3df" "fea40a8b93606b2fc977192b0be1108448fbcfe4" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libhwsec-foundation tpm_manager .gn"

PLATFORM_SUBDIR="tpm_manager/client"

inherit cros-workon platform

DESCRIPTION="TPM Manager D-Bus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/tpm_manager/client/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test tpm tpm2 fuzzer"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

COMMON_DEPEND="
	chromeos-base/system_api:=[fuzzer?]
	dev-libs/openssl:0=
	dev-libs/protobuf:=
"

# Workaround to rebuild this package on the chromeos-dbus-bindings update.
# Please find the comment in chromeos-dbus-bindings for its background.
DEPEND="${COMMON_DEPEND}
	chromeos-base/chromeos-dbus-bindings:=
"

# Note that for RDEPEND, we conflict with tpm_manager package older than
# 0.0.1 because this client is incompatible with daemon older than version
# 0.0.1. We didn't RDEPEND on tpm_manager version 0.0.1 or greater because
# we don't want to create circular dependency in case the package tpm_manager
# depends on some package foo that also depend on this package.
RDEPEND="${COMMON_DEPEND}
	!<chromeos-base/tpm_manager-0.0.1-r2238
"

src_install() {
	platform_src_install

	# Install D-Bus client library.
	platform_install_dbus_client_lib "tpm_manager"

	dobin "${OUT}"/tpm_manager_client

	dolib.so "${OUT}"/lib/libtpm_manager.so

	# Install header files.
	insinto /usr/include/tpm_manager/client
	doins ./*.h
	insinto /usr/include/tpm_manager/common
	doins ../common/*.h
	doins "${OUT}"/gen/tpm_manager/common/*.h
}

platform_pkg_test() {
	local tests=(
		tpm_manager-client_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
