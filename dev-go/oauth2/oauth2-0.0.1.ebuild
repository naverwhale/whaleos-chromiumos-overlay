# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="go.googlesource.com/oauth2:golang.org/x/oauth2 fdc9e635145ae97e6c2cb777c48305600cf515cb"

CROS_GO_PACKAGES=(
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/internal"
	"golang.org/x/oauth2/jws"
	"golang.org/x/oauth2/jwt"
	"golang.org/x/oauth2/google"
)

CROS_GO_TEST=(
	"golang.org/x/oauth2"
	#Flaky: "golang.org/x/oauth2/internal"
	"golang.org/x/oauth2/jws"
	"golang.org/x/oauth2/jwt"
	# Needs to import "google.golang.org/appengine", which we don't have.
	# "golang.org/x/oauth2/google"
)

inherit cros-go

DESCRIPTION="Go packages for oauth2"
HOMEPAGE="https://golang.org/x/oauth2"
SRC_URI="$(cros-go_src_uri)"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="dev-go/gcp-compute"
RDEPEND="${DEPEND}"
