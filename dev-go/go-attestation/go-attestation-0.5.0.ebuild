# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_GO_SOURCE="github.com/google/go-attestation v${PV}"

CROS_GO_PACKAGES=(
	"github.com/google/go-attestation/attest"
	"github.com/google/go-attestation/attest/internal"
)

inherit cros-go

DESCRIPTION="Package attest abstracts TPM attestation operations"
HOMEPAGE="https://github.com/google/go-attestation"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/go-tspi dev-go/go-tpm"
RDEPEND=""
