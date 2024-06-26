# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT="chromiumos/platform/tremplin"
CROS_WORKON_LOCALNAME="platform/tremplin"
CROS_GO_BINARIES="chromiumos/tremplin"

CROS_GO_TEST=(
	"chromiumos/tremplin/..."
)
CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Tremplin LXD client with gRPC support"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tremplin/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE=""

COMMON_DEPEND="
	app-emulation/lxd:4
	app-emulation/lxd:5
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/vm_guest_tools:=
	chromeos-base/vm_protos:=
	dev-go/go-libaudit:=
	dev-go/go-sys:=
	dev-go/grpc:=
	dev-go/netlink:=
	dev-go/vsock:=
	dev-go/yaml:0
"

RDEPEND="${COMMON_DEPEND}"
