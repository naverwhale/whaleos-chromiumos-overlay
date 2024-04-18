# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "4df5bfcbc1310473ac5466277b07a7b669d1e02c" "0a73e14ae1ced1296f87bfeeacd2917bf320a575")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

CROS_WORKON_SUBTREE="common-mk .gn resourced/src/vm_grpc/proto resourced/vm_grpc/interface"

PLATFORM_SUBDIR="resourced/vm_grpc/interface"

inherit cros-go cros-workon platform

DESCRIPTION="Resourced lib to interact with resourced. Usable on Chrome OS and Guest VM"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/resourced"

LICENSE="BSD-Google"
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/minijail:=
	net-libs/grpc:=
	dev-libs/protobuf:=
	dev-go/protobuf-legacy-api:=
"

RDEPEND="
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
	dev-go/grpc:=
	dev-go/protobuf:=
	sys-kernel/linux-headers:=
"

src_install() {
	platform_src_install

	dolib.so "${OUT}"/lib/libresourceD.so
}
