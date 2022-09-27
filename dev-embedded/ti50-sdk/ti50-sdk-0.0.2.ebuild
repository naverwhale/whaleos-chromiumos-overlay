# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit cros-constants python-any-r1 toolchain-funcs

DESCRIPTION="Ebuild that installs Ti50's SDK"
LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
KEYWORDS="*"
SLOT="0"

# The llvm src tarball was manually packed from a checkout of
# https://github.com/llvm/llvm-project at ${LLVM_SHA}, using
# ${FILESDIR}/pack_git_tarball.py.
LLVM_SHA="bb852a09ae36"
LLVM_SRC_TARBALL_NAME="llvm-${LLVM_SHA}-src"
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${LLVM_SRC_TARBALL_NAME}.tar.xz"


# The rust src tarball was manually packed from a checkout of
# https://github.com/rust-lang/rust at ${RUST_SHA}, using
# ${FILESDIR}/pack_git_tarball.py with |--post-copy-command 'cargo vendor'|.
BOOTSTRAP_HOST_TRIPLE="x86_64-unknown-linux-gnu"
RUST_SHA="9111b8ae9793"
# See https://github.com/rust-lang/rust/tree/${RUST_SHA}/src/stage0.txt
RUST_STAGE0_DATE="2021-05-23"

RUST_PREFIX="rust-${RUST_SHA}"
RUST_SRC_TARBALL_NAME="rustc-${RUST_SHA}-src"
RUST_CARGO_TARBALL_NAME="cargo-beta-${BOOTSTRAP_HOST_TRIPLE}"
RUST_STAGE0_TARBALL_NAME="rustc-beta-${BOOTSTRAP_HOST_TRIPLE}"
RUST_STD_TARBALL_NAME="rust-std-beta-${BOOTSTRAP_HOST_TRIPLE}"
RUST_RUSTFMT_TARBALL_NAME="rustfmt-beta-${BOOTSTRAP_HOST_TRIPLE}"
SRC_URI+="
	https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${RUST_PREFIX}-${RUST_SRC_TARBALL_NAME}.tar.xz
	https://static.rust-lang.org/dist/${RUST_STAGE0_DATE}/${RUST_CARGO_TARBALL_NAME}.tar.xz -> ${RUST_PREFIX}-${RUST_CARGO_TARBALL_NAME}.tar.xz
	https://static.rust-lang.org/dist/${RUST_STAGE0_DATE}/${RUST_STAGE0_TARBALL_NAME}.tar.xz -> ${RUST_PREFIX}-${RUST_STAGE0_TARBALL_NAME}.tar.xz
	https://static.rust-lang.org/dist/${RUST_STAGE0_DATE}/${RUST_STD_TARBALL_NAME}.tar.xz -> ${RUST_PREFIX}-${RUST_STD_TARBALL_NAME}.tar.xz
	https://static.rust-lang.org/dist/${RUST_STAGE0_DATE}/${RUST_RUSTFMT_TARBALL_NAME}.tar.xz -> ${RUST_PREFIX}-${RUST_RUSTFMT_TARBALL_NAME}.tar.xz
"

# The newlib src tarball was manually packed from a checkout of
# https://sourceware.org/git/newlib-cygwin.git at ${NEWLIB_SHA}, using
# ${FILESDIR}/pack_git_tarball.py.
NEWLIB_SHA="1debd4d635c2"
NEWLIB_SRC_TARBALL_NAME="newlib-${NEWLIB_SHA}-src"
SRC_URI+=" https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${NEWLIB_SRC_TARBALL_NAME}.tar.xz"

SRC_ROOT="${WORKDIR}/${P}/src"
INSTALL_ROOT="${WORKDIR}/${P}/install"
INSTALL_PREFIX="opt/${PN}"

# N.B., this toolchain is built entirely independently of the host's Rust
# toolchain, so no dev-lang/rust dependency is needed.
DEPEND="sys-libs/zlib
	>=sys-libs/ncurses-5.9-r3
	sys-devel/binutils"
BDEPEND="${PYTHON_DEPS}
	dev-lang/perl
	sys-devel/gnuconfig
	$(python_gen_any_dep 'dev-python/sphinx[${PYTHON_USEDEP}]')
	>=dev-libs/libxml2-2.9.6
	>=dev-lang/perl-5.0"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_unpack() {
	default

	mkdir -p "${SRC_ROOT}" || die

	mv "${WORKDIR}/${LLVM_SRC_TARBALL_NAME}" "${SRC_ROOT}/llvm" || die
	mv "${WORKDIR}/${NEWLIB_SRC_TARBALL_NAME}" "${SRC_ROOT}/newlib" || die

	mv "${WORKDIR}/${RUST_SRC_TARBALL_NAME}" "${SRC_ROOT}/rustc" || die
	cp -r \
		"${WORKDIR}/${RUST_STD_TARBALL_NAME}/rust-std-${BOOTSTRAP_HOST_TRIPLE}/lib/rustlib/${BOOTSTRAP_HOST_TRIPLE}" \
		"${WORKDIR}/${RUST_STAGE0_TARBALL_NAME}/rustc/lib/rustlib" \
		|| die
}

src_prepare() {
	cd "${SRC_ROOT}/llvm" || die
	eapply "${FILESDIR}/llvm11-10122020-soteria.patch"

	cd "${SRC_ROOT}/rustc" || die

	# Copy "unknown" vendor targets to create cros_sdk target triples applied later.
	local spec_dir="compiler/rustc_target/src/spec"
	sed -e 's|"unknown"|"pc"|g' "${spec_dir}/x86_64_unknown_linux_gnu.rs" \
		> "${spec_dir}/x86_64_pc_linux_gnu.rs" \
		|| die

	eapply "${FILESDIR}/rust-add-cros-targets.patch"
	sed -i 's|"stdc++"|"c++"|g' "compiler/rustc_llvm/build.rs" || die

	cd "${SRC_ROOT}/rustc/src/llvm-project/" || die
	eapply "${FILESDIR}/rust-llvm-prf.patch"

	cd "${SRC_ROOT}" || die
	eapply_user
}

# src_configure is elided, since this package is actually building a few things
# at once, and there are dependencies between these things. Ideally, each of
# these would be their own ebuild, but we're trying to keep this as small and
# self-contained as possible for the moment.

src_compile() {
	tc-export PKG_CONFIG

	# In iterative development via `ebuild compile`, our clang toolchain
	# might already be fully built. Don't rebuild it if that's the case.
	if [[ ! -e "${INSTALL_ROOT}/bin/clang" ]]; then
		"${FILESDIR}/build_clang_toolchain.py" \
			--install-dir="${INSTALL_ROOT}" \
			--llvm-dir="${SRC_ROOT}/llvm" \
			--newlib-dir="${SRC_ROOT}/newlib" \
			--work-dir="${SRC_ROOT}/llvm/build" \
			|| die
	fi

	"${FILESDIR}/build_rust_toolchain.py" \
		--install-dir="${INSTALL_ROOT}" \
		--install-prefix="${ED}${INSTALL_PREFIX}" \
		--rust-src="${SRC_ROOT}/rustc" \
		--rv-clang-bin="${INSTALL_ROOT}/bin" \
		--cargo="${WORKDIR}/${RUST_CARGO_TARBALL_NAME}/cargo/bin/cargo" \
		--rustc="${WORKDIR}/${RUST_STAGE0_TARBALL_NAME}/rustc/bin/rustc" \
		--rustfmt="${WORKDIR}/${RUST_RUSTFMT_TARBALL_NAME}/rustfmt-preview/bin/rustfmt" \
		|| die
}

src_install() {
	dodir "/${INSTALL_PREFIX}"
	cp -a "${INSTALL_ROOT}"/* "${D}/${INSTALL_PREFIX}" || die
}
