# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk metrics thinpool_migrator .gn"

PLATFORM_SUBDIR="thinpool_migrator"

inherit cros-workon platform

DESCRIPTION="Thinpool migrator for ChromiumOS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/thinpool_migrator/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="+device_mapper -lvm_stateful_partition"

COMMON_DEPEND="
	chromeos-base/metrics:=
	dev-libs/protobuf
	sys-apps/rootdev:=
	device_mapper? ( sys-fs/lvm2:=[thin] )
	lvm_stateful_partition? ( sys-fs/lvm2:= )
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"

platform_pkg_test() {
	platform test_all
}
