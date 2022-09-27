# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE=(
	"github.com/hashicorp/go.net 104dcad90073cd8d1e6828b2af19185b60cf3e29"
	"github.com/hashicorp/mdns 4e527d9d808175f132f949523e640c699e4253bb"
)

CROS_GO_PACKAGES=(
	"github.com/hashicorp/go.net/internal/iana"
	"github.com/hashicorp/go.net/ipv4"
	"github.com/hashicorp/go.net/ipv6"
	"github.com/hashicorp/mdns"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="Simple mDNS client/server library in Golang"
HOMEPAGE="https://github.com/hashicorp/mdns"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/dns"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/gonet-arm64.patch"
}
