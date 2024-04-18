# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/mitchellh/go-homedir af06845cf3004701891bf4fdb884bfe4920b3727"

CROS_GO_PACKAGES=(
	"github.com/mitchellh/go-homedir"
)

inherit cros-go

DESCRIPTION="Go library for detecting and expanding the user's home directory without cgo. "
HOMEPAGE="https://github.com/mitchellh/go-homedir"
SRC_URI="$(cros-go_src_uri)"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
RDEPEND="!<=dev-go/luci-go-cipd-0.0.1-r1"
