# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/moby/sys c161267cd2212985f81a50a029001f82c91bca7f"

CROS_GO_PACKAGES=(
	"github.com/moby/sys/mount"
)

inherit cros-go

DESCRIPTION="Module mount provides a set of functions to mount and unmount mounts"
HOMEPAGE="https://github.com/moby/sys"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
RESTRICT="binchecks strip"
DEPEND="dev-go/mountinfo"
RDEPEND="!<=dev-go/moby-0.5.0"
