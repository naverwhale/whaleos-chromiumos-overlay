# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_SUBTREE="crosh"

inherit cros-workon cros-rust

DESCRIPTION="Chrome OS developer command-line shell"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/crosh/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"
IUSE="+rust-crosh"

DEPEND="
	=dev-rust/chrono-0.4*:=
	=dev-rust/dbus-0.9*:=
	=dev-rust/getopts-0.2*:=
	dev-rust/libchromeos:=
	=dev-rust/rand-0.7*:=
	>=dev-rust/regex-1.0.6:= <dev-rust/regex-2.0.0
	dev-rust/remain:=
	=dev-rust/rustyline-7*:=
	dev-rust/shell-words:=
	dev-rust/sys_util:=
	dev-rust/system_api:=
	dev-rust/tempfile:=
	>dev-rust/tlsdate_dbus-0.24.52-r8:=
"
RDEPEND="app-admin/sudo
	chromeos-base/vboot_reference
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	sys-apps/dbus
	sys-apps/net-tools
"

src_compile() {
	# File order is important here.
	sed \
		-e '/^#/d' \
		-e '/^$/d' \
		inputrc.safe inputrc.extra \
		> "${WORKDIR}"/inputrc.crosh || die

	cros-rust_src_compile
}

src_test() {
	./run_tests.sh || die

	local args=()
	# (b/197637613) reduce the number of futex calls to reduce the risk of a hang
	# when running inside qemu.
	if ! cros_rust_is_direct_exec; then
		args+=( -- --test-threads=1 )
	fi

	cros-rust_src_test "${args[@]}"
}

src_install() {
	if use rust-crosh; then
		dobin "$(cros-rust_get_build_dir)/crosh"
		newbin crosh crosh.sh
	else
		dobin crosh
	fi
	dobin network_diag
	local d="/usr/share/crosh"
	insinto "${d}/dev.d"
	doins dev.d/*.sh
	insinto "${d}/removable.d"
	doins removable.d/*.sh
	insinto "${d}"
	doins "${WORKDIR}"/inputrc.crosh
}
