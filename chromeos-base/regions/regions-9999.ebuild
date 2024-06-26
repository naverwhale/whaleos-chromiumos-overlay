# Copyright 2015 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )
inherit python-any-r1

CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="regions"

PLATFORM_SUBDIR="regions"

inherit cros-workon

DESCRIPTION="Chromium OS Region Data"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/regions/"
LICENSE="BSD-Google"
KEYWORDS="~*"

IUSE="cros-debug"

# 'jq' allows command line tools to access the JSON database.
RDEPEND="app-misc/jq"
DEPEND=""

# shellcheck disable=SC2016
BDEPEND="
	$(python_gen_any_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"

python_check_deps() {
	python_has_version -b "dev-python/pyyaml[${PYTHON_USEDEP}]"
}

src_unpack() {
	cros-workon_src_unpack
	S+="/regions"
}

src_compile() {
	./regions.py --format=json --output "${WORKDIR}/cros-regions.json" $(usex cros-debug "--include_pseudolocales" "") || die
}

src_test() {
	./regions_unittest.py || die
}

src_install() {
	dobin cros_region_data

	insinto /usr/share/misc
	doins "${WORKDIR}/cros-regions.json"
}
