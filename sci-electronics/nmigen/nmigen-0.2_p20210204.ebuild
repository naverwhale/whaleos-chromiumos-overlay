# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1

DESCRIPTION="A refreshed Python toolbox for building complex digital hardware."
HOMEPAGE="https://github.com/nmigen/nmigen"

GIT_REV="f7c2b9419f9de450be76a0e9cf681931295df65f"
SRC_URI="https://github.com/nmigen/${PN}/archive/${GIT_REV}.tar.gz -> ${PN}-${GIT_REV}.tar.gz"

# Provide the version since `setuptools_scm` breaks emerging snapshot ebuilds.
# `python3 -m setuptools_scm` can be used inside a repository to print version
# corresponding to the checked-out commit.
export SETUPTOOLS_SCM_PRETEND_VERSION="0.3.dev243+gf7c2b94"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

# Versioned setup.py deps: "pyvcd~=0.2.2", "Jinja2~=2.11".
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/importlib_metadata[${PYTHON_USEDEP}]
	' python3_{6..7})
	>=dev-python/jinja-2.11[${PYTHON_USEDEP}] =dev-python/jinja-2*
	>=dev-python/pyvcd-0.2.2[${PYTHON_USEDEP}] =dev-python/pyvcd-0.2*
	>=sci-electronics/yosys-0.9
"
BDEPEND="
	dev-python/setuptools_scm[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${PN}-${GIT_REV}"

PATCHES="
	${FILESDIR}/nmigen-0.2_p20210204-fix-cxx-executable.patch
	${FILESDIR}/nmigen-0.2_p20210204-fix-setup.patch
"

src_test() {
	if ! has_version sci-electronics/symbiyosys; then
		ewarn "SymbiYosys not found; skipping tests that require it."
		eapply "${FILESDIR}/nmigen-0.2_p20210204-skip-tests-using-symbiyosys.patch"
	fi

	distutils-r1_src_test
}

# Apart from declaring `python_test`, `distutils_enable_tests` also manages test
# dependencies and flags. Let's keep it even though the function is overridden.
distutils_enable_tests unittest
python_test() {
	distutils_install_for_testing

	"${EPYTHON}" -m unittest discover -v || die "Tests fail with ${EPYTHON}"
}
