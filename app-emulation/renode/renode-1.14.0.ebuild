# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the BSD license.

EAPI=7

PYTHON_COMPAT=( python3_{7..11} )
inherit python-r1 multiprocessing

DESCRIPTION="Renode is an open source software development framework with
commercial support from Antmicro that lets you develop, debug and test
multi-node device systems reliably, scalably and effectively."
HOMEPAGE="https://renode.io"

SRC_URI="https://dl.antmicro.com/projects/renode/builds/renode_${PV}_source.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

DEPEND="
	>=dev-lang/mono-5.20
	$(python_gen_cond_dep '
		=dev-python/robotframework-4.0.1[${PYTHON_USEDEP}]
		dev-python/netifaces[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"
RDEPEND="
	${DEPEND}
"

S="${WORKDIR}/renode_${PV}_source"

src_compile() {
	./build.sh --no-gui --skip-fetch || die
}

src_install() {
	cd tools/packaging || die

	# Set variables required by the 'common_copy_files.sh' script.
	sed -i \
		-e '1iOS_NAME=linux' \
		-e '1iSED_COMMAND="sed -i"' \
		-e "1iBASE=${S}" \
		-e '1iTARGET=Release' \
		-e '1iINSTALL_DIR="/opt/renode"' \
		-e "1iDIR=\"${ED}/opt/renode\"" \
		common_copy_files.sh || die

	(
		# Call die in case any of the commands fail (incl. sourced scripts).
		trap die ERR

		# Use a subshell to avoid leaking env back into the ebuild.
		# shellcheck disable=SC1091
		. ./common_copy_files.sh || die

		local common_script="${ED}"/opt/renode/tests/common.sh
		local test_script=renode-test
		# Calling it here as it's a function inside common_copy_files.sh
		copy_bash_tests_scripts "${test_script}" "${common_script}" || die
	)

	# Create renode and renode-test wrappers.
	local command_script=renode
	local mono_version="$(cat ../mono_version)"
	cat > "${command_script}" <<-EOF || die
		#!/bin/sh
		MONOVERSION=${mono_version}
		REQUIRED_MAJOR=${mono_version%%.*}
		REQUIRED_MINOR=${mono_version##*.}
		EOF
	# skip the first line (with the shebang)
	tail -n +2 linux/renode-template >> "${command_script}" || die
	dobin renode
	dobin renode-test
}

src_test() {
	./renode --version || die
	./renode --console -e 'help; version; quit' || die

	# Run such unit tests that don't need to download any binaries.
	local test_script="${PWD}/renode-test"
	cd tests/unit-tests || die
	local tests=(
		AdHocCompiler/adhoc-compiler.robot
		arm-thumb.robot
		big-endian-watchpoint.robot
		emulation-environment.robot
		host-uart.robot
		llvm-disassemble.robot
		log-tests.robot
		memory-invalidation.robot
		opcodes-counting.robot
		riscv-custom-instructions.robot
		riscv-interrupt-mode.robot
		riscv-unit-tests.robot
		tb_overwrite.robot
	)
	${test_script} --stop-on-error -j "$(makeopts_jobs)" "${tests[@]}" || die
}
