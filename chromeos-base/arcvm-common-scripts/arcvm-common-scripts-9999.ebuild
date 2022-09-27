# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/vm/scripts .gn"

inherit cros-workon

DESCRIPTION="ARCVM common scripts."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/vm/scripts"

LICENSE="BSD-Google"
KEYWORDS="~*"

RDEPEND="
	${RDEPEND}
	!<=chromeos-base/arc-base-0.0.1-r349
	!<=chromeos-base/arc-common-scripts-0.0.1-r132
	chromeos-base/arcvm-mount-media-dirs
"

src_install() {
	dosbin arc/vm/scripts/android-sh

	insinto /etc/init
	doins arc/vm/scripts/init/arcvm-fsverity-certs.conf
	doins arc/vm/scripts/init/arcvm-host.conf
	doins arc/vm/scripts/init/arcvm-post-login-services.conf
	doins arc/vm/scripts/init/arcvm-post-vm-start-services.conf
	doins arc/vm/scripts/init/arcvm-pre-login-services.conf
	doins arc/vm/scripts/init/arcvm-ureadahead.conf

	insinto /etc/dbus-1/system.d
	doins arc/vm/scripts/init/dbus-1/ArcVmScripts.conf

	insinto /usr/share/arcvm
	doins arc/vm/scripts/init/config.json

	insinto /usr/share/arcvm/fsverity-certs
	doins arc/vm/scripts/init/certs/fsverity-release.x509.der
	doins arc/vm/scripts/init/certs/play_store_fsi_cert.der

	# Redirect ARCVM logs to arc.log.
	insinto /etc/rsyslog.d
	doins arc/vm/scripts/rsyslog.arc.conf
}
