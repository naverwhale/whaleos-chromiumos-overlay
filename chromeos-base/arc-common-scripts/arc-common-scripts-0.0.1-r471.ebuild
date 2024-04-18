# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "3c7a0977390418eab32ee8f759e77a8c42ffd319" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/container/scripts .gn"

inherit cros-workon

DESCRIPTION="ARC++ common scripts."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/arc/container/scripts"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

IUSE="arcpp"
RDEPEND="
	!<=chromeos-base/arc-base-0.0.1-r349
	!<chromeos-base/arc-setup-0.0.1-r1084
	app-misc/jq"
DEPEND=""

src_install() {
	dosbin arc/container/scripts/android-sh
	insinto /etc/init
	doins arc/container/scripts/arc-kmsg-logger.conf
	doins arc/container/scripts/arc-set-time.conf
	doins arc/container/scripts/arc-ureadahead.conf
	insinto /etc/sysctl.d
	doins arc/container/scripts/01-sysctl-arc.conf
	# Redirect ARC logs to arc.log.
	insinto /etc/rsyslog.d
	doins arc/container/scripts/rsyslog.arc.conf
}
