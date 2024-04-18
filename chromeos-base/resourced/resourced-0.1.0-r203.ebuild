# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="b05440c307c2ae209b04ca197513629b0e7704f0"
CROS_WORKON_TREE="8b6dad847b15dbccbc9e578b9b5499dcf65ac881"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since project's Cargo.toml is
# using "provided by ebuild" macro which supported by cros-rust.
CROS_WORKON_SUBTREE="resourced"

inherit cros-workon cros-rust udev user

DESCRIPTION="ChromeOS Resource Management Daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/resourced/"

LICENSE="BSD-Google"
SLOT="0/${PVR}"
KEYWORDS="*"
IUSE="+seccomp"

RDEPEND="
	chromeos-base/featured:=
	chromeos-base/metrics:=
	dev-libs/openssl:0=
	sys-apps/dbus:=
"
DEPEND="
	${RDEPEND}
	dev-rust/third-party-crates-src:=
	dev-rust/featured:=
	dev-rust/libchromeos:=
	dev-rust/metrics_rs:=
	dev-rust/system_api:=
"

BDEPEND="
	chromeos-base/minijail
"

src_compile() {
	local features=(
		chromeos
	)

	ecargo_build -v \
		--features="${features[*]}" ||
		die "cargo build failed"
}

src_test() {
	# Single threaded test execution to reduce test flakiness
	cros-rust_src_test -- --test-threads=1
}

src_install() {
	dobin "$(cros-rust_get_build_dir)/resourced"

	# D-Bus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.ResourceManager.conf

	# init script.
	insinto /etc/init
	doins init/resourced.conf

	# Minijail configuration.
	insinto /usr/share/minijail
	doins minijail/resourced.conf

	# Install udev rules.
	udev_dorules udev/99-resourced.rules

	if [[ -d tmpfiles.d ]]; then
		insinto /usr/lib/tmpfiles.d
		doins -r tmpfiles.d/*
	fi

	# seccomp policy file.
	insinto /usr/share/policy
	if use seccomp; then
		newins "seccomp/resourced-seccomp-${ARCH}.policy" resourced-seccomp.policy
	fi
}

pkg_preinst() {
	enewuser "resourced"
	enewgroup "resourced"

	cros-rust_pkg_preinst
}
