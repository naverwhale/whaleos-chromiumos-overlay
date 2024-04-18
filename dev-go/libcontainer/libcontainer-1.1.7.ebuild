# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/opencontainers/runc v${PV}"

CROS_GO_PACKAGES=(
	"github.com/opencontainers/runc/libcontainer/user"
)

inherit cros-go

DESCRIPTION="Libcontainer provides a native Go implementation for creating containers with namespaces, cgroups, capabilities, and filesystem access controls"
HOMEPAGE="https://github.com/opencontainers/runc/libcontainer"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"
RDEPEND="!<=dev-go/docker-20.10.8-r1"
