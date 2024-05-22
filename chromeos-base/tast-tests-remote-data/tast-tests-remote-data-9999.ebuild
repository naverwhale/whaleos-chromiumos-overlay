# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_PROJECT=(
	"chromiumos/platform/tast-tests"
	"chromiumos/platform/fw-testing-configs"
)
CROS_WORKON_LOCALNAME=(
	"platform/tast-tests"
	"platform/tast-tests/src/go.chromium.org/tast-tests/cros/remote/firmware/data/fw-testing-configs"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/src/go.chromium.org/tast-tests/cros/remote/firmware/data/fw-testing-configs"
)

# There are symlinks between remote data to local data, so we can't make the
# subtree "src/go.chromium.org/tast-tests/cros"/remote".
# TODO(oka): have a clear separation between local and remote, and make that
# happen.
CROS_WORKON_SUBTREE=("src/go.chromium.org/tast-tests/cros")
TAST_BUNDLE_ROOT="go.chromium.org/tast-tests/cros"

inherit cros-workon tast-bundle-data

DESCRIPTION="Data files for remote Tast tests"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tast-tests"

LICENSE="BSD-Google GPL-3"
SLOT="0/0"
KEYWORDS="~*"

RDEPEND="!<chromeos-base/tast-remote-tests-cros-0.0.2"

src_install() {
	tast-bundle-data_src_install
}
