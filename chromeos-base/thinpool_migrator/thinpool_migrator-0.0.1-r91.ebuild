# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "0461d8b445c2bef30e220363c7f58ced1918b444" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
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
KEYWORDS="*"
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
