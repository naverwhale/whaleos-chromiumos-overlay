# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# python_requires='>=3.5'
PYTHON_COMPAT=( python3_{5..9} )
inherit distutils-r1

DESCRIPTION="Python module containing verilog files for VexRISCV cpu."
HOMEPAGE="https://github.com/litex-hub/pythondata-cpu-vexriscv"

# Not on a master branch.
GIT_REV="2b6855412cdbde5e31bde13283e49976247ba90b"
SRC_URI="https://github.com/litex-hub/${PN}/archive/${GIT_REV}.tar.gz -> ${PN}-${GIT_REV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}/${PN}-${GIT_REV}"

python_test() {
	"${EPYTHON}" test.py || die "Tests fail with ${EPYTHON}"
}
