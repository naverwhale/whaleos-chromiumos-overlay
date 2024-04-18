# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="28855525b6c452b8822c99272354f0aece775a5d"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "b549eeb0fc6b1a5d80697379359d2567e678bd73" "ce84e9b1511f8a8a2389efe0a3a5c45b49fb817d" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk spaced system_api .gn"

PLATFORM_SUBDIR="spaced"

inherit cros-workon platform user

DESCRIPTION="Disk space information daemon for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/spaced/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="+seccomp"

RDEPEND="
	dev-libs/protobuf:=
	sys-apps/rootdev:=
"
DEPEND="
	${RDEPEND}
	chromeos-base/system_api:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

pkg_preinst() {
	enewuser "spaced"
	enewgroup "spaced"
}

src_install() {
	platform_src_install
	platform_install_dbus_client_lib

	if use seccomp; then
		local policy="seccomp/spaced-seccomp-${ARCH}.policy"
		local policy_out="${ED}/usr/share/policy/spaced-seccomp.policy.bpf"
		dodir /usr/share/policy
		compile_seccomp_policy \
			--arch-json "${SYSROOT}/build/share/constants.json" \
			--default-action trap "${policy}" "${policy_out}" \
			|| die "failed to compile seccomp policy ${policy}"
	fi
}

platform_pkg_test() {
	platform test_all
}
