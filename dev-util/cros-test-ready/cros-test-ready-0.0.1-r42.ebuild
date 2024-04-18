# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT=("1e7a836627664f80fc83188d0a5c9405b8d26727" "06319ab76042c569149904fcc25a251ad6926956")
CROS_WORKON_TREE=("b19a06e06c2031617e28402f02efb418a910dcb9" "fd5b651818f5633d6715a2145590e096ff7d4439")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/dev-util"
	"chromiumos/config"
)

CROS_WORKON_LOCALNAME=(
	"../platform/dev"
	"../config"
)

CROS_WORKON_SUBTREE=(
	"src/chromiumos/test/check"
	"python"
)

CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/config"
)

PYTHON_COMPAT=( python3_{8..11} )

inherit cros-go cros-workon python-any-r1

DESCRIPTION="Utility to check if a DUT is ready to be used for testing"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/dev-util/+/HEAD/src/chromiumos/test/check"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

CROS_GO_VERSION="${PF}"

CROS_GO_BINARIES=(
	"chromiumos/test/check/cmd/cros_test_ready"
)

CROS_GO_TEST=(
	"chromiumos/test/check/cmd/cros_test_ready/..."
)

CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

DEPEND="
	chromeos-base/cros-config-api
	chromeos-base/autotest-client
	chromeos-base/tast-local-tests-cros
	dev-go/protobuf-legacy-api
	dev-go/subcommands
"

BDEPEND="
	$(python_gen_any_dep '
		chromeos-base/cros-config-api[${PYTHON_USEDEP}]
		dev-python/protobuf-python[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')
"

python_check_deps() {
	python_has_version -b \
		"chromeos-base/cros-config-api[${PYTHON_USEDEP}]" \
		"dev-python/protobuf-python[${PYTHON_USEDEP}]" \
		"dev-python/six[${PYTHON_USEDEP}]"
}

pkg_setup() {
	cros-workon_pkg_setup
	python_setup
}

src_prepare() {
	export CGO_ENABLED=0
	export GOPIE=0

	default
}

src_install() {
	default
	cros-go_src_install
	# Set the path for the configure file generator.
	local generator="${S}/src/chromiumos/test/check/python/cros_test_ready_config_generator.py"
	local path="${WORKDIR}/cros_test_ready_config.jsonpb"

	export PYTHONDONTWRITEBYTECODE=1
	"${generator}" -src_root "${ROOT}" -output_file="${path}" || die

	insinto /etc
	doins "${path}"
}
