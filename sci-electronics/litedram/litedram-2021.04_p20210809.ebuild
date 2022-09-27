# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1

DESCRIPTION="LiteDRAM provides a small footprint and configurable DRAM core."
HOMEPAGE="https://github.com/enjoy-digital/litedram"

GIT_REV="203cc73cebec56faa0ed5c8900e15ac2c1dfe32b"
SRC_URI="https://github.com/enjoy-digital/${PN}/archive/${GIT_REV}.tar.gz -> ${PN}-${GIT_REV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-python/pyyaml[${PYTHON_USEDEP}]
	sci-electronics/litex[${PYTHON_USEDEP}]
	sci-electronics/migen[${PYTHON_USEDEP}]
	test? (
		sci-electronics/pythondata-cpu-vexriscv[${PYTHON_USEDEP}]
		|| (
			cross-riscv64-cros-elf/gcc
			cross-riscv32-cros-elf/gcc
		)
	)
"

S="${WORKDIR}/${PN}-${GIT_REV}"

distutils_enable_tests unittest

src_test() {
	# All tests require 'litex_boards' module.
	mv test/{,skipped-}test_init.py || die

	# This particular test requires 'pythondata-cpu-serv' module.
	sed -i -e 's#\([ ]\+\)def test_ulx3s#\1@unittest.skip("Serv CPU test")\n&#' \
		test/test_examples.py || die

	# Tests belonging to Verilator...Tests class require Verilator. There are
	# other tests in 'test_lpddr4.py' though, so only the class is skipped.
	if ! has_version sci-electronics/verilator; then
		sed -i -e 's#class Verilator.*Tests#@unittest.skip("No Verilator")\n&#' \
			test/test_lpddr4.py || die
	fi

	distutils-r1_src_test
}
