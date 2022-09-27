# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="54c7fac37782fd4a975d5ac8982da4ef9423fda7"
CROS_WORKON_TREE=("d897a7a44e07236268904e1df7f983871c1e1258" "4110b1743a3f308203c6d1dd85bf191e0dbda2ca" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk missive .gn"

PLATFORM_SUBDIR="missive"

inherit cros-workon platform user

DESCRIPTION="Daemon to encrypt, store, and forward reporting events for managed devices."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/missive/"

LICENSE="BSD-Google"
SLOT=0/0
KEYWORDS="*"
IUSE=""

RDEPEND="
	app-arch/snappy
	chromeos-base/minijail:=
	dev-libs/protobuf:=
"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api:=
"

pkg_preinst() {
	enewuser missived
	enewgroup missived
}

src_install() {
	# Install binary
	dobin "${OUT}"/missived

	# Install upstart configurations
	insinto /etc/init
	doins init/missived.conf

	# TODO(zatrudo): Generate at end of devleopment before release.
	# Install seccomp policy file.
	#insinto /usr/share/policy
	#newins "seccomp/missived-seccomp-${ARCH}.policy" missived-seccomp.policy

	# Install D-Bus configuration file.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Missived.conf

	# Install D-Bus service activation configuration.
	insinto /usr/share/dbus-1/system-services
	doins dbus/org.chromium.Missived.service

	# Install rsyslog config.
	# TODO(zatrudo): Determine if logs from this daemon should be redirected.
	#insinto /etc/rsyslog.d
	#doins rsyslog/rsyslog.missived.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/missived_testrunner"
}
