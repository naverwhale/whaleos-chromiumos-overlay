# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=7
CROS_WORKON_COMMIT=("dc153a30570d4bae6a99c30b30fe0d94ef1be59c" "ac2e1a752cdedb3879daa79a657cf4e1ffdd639c")
CROS_WORKON_TREE=("030eb32017711e3bed6e6b3a94d66f9f93cb4131" "004d69667991fed6fdc5c41f706f6d8de5a4116b" "5954704d5f30d3fe3c21aab2d249ae00bddc1760" "3c4c2d1f78d70547ae755c56c69f969581b0b975" "6862f9c9dfc325a641da7b72a18ce048cbc09d97" "46a40d0d85cd9ad718e03f158c0bbdc30da23968" "30cc0ecbbf814acd8a29dd2044e3d266afa3ff6e" "a7657b348c5a8426cdf6358ce41d8bd551daebde" "007bbccdbe3a9583d5b3edd1cb3dab919df41d4f" "83dfbbe5c697b3f246c8c2b5d0ab987ec4027e32" "5d571b60cf18aaca5199bfa5fe231e88465fdd17" "30b301e5f4f1bf6703521fb794c5a53fbff7349b" "d81ce78ca82f241cfc0473b4bd037c9f541a40db" "3c7de6316ebdc7d62b958199ee523fd303e314d7" "270f0b93b199814e88671a10bbdc338e2e28531b" "0aa1ed596daf0e1c2011889a39a1e9b7bb31dfd5" "f9660e0eadff1f6e87a84f57c9862c49f4dbde66")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/coreboot"
	"chromiumos/platform/vboot_reference"
)
CROS_WORKON_LOCALNAME=(
	"coreboot"
	"../platform/vboot_reference"
)
CROS_WORKON_DESTDIR=(
	"${S}"
	"${S}/3rdparty/vboot"
)
CROS_WORKON_EGIT_BRANCH=(
	"chromeos-2016.05"
	"main"
)

# coreboot:src/arch/x85/include/arch: used by inteltool, x86 only
# coreboot:src/commonlib: used by cbfstool
# coreboot:src/vendorcode/intel: used by cbfstool
# coreboot:util/*: tools built by this ebuild
# vboot: minimum set of files and directories to build vboot_lib for cbfstool
CROS_WORKON_SUBTREE=(
	"src/arch/x86/include/arch src/commonlib src/vendorcode/intel util/archive util/cbmem util/cbfstool util/ifdtool util/inteltool util/mma util/nvramtool util/superiotool util/amdfwtool"
	"Makefile cgpt host firmware futility"
)

inherit cros-workon toolchain-funcs cros-sanitizers

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host mma +pci static"

BDEPEND="virtual/pkgconfig"

LIB_DEPEND="
	dev-libs/openssl[static-libs(+)]
	sys-apps/pciutils[static-libs(+)]
	sys-apps/flashrom
"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
"

_emake() {
	emake \
		TOOLLDFLAGS="${LDFLAGS}" \
		CC="${CC}" \
		STRIP="true" \
		"$@"
}

src_configure() {
	sanitizers-setup-env
	use static && append-ldflags -static
	tc-export CC PKG_CONFIG
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	_emake -C util/cbfstool obj="${PWD}/util/cbfstool"
	if use cros_host; then
		_emake -C util/archive HOSTCC="${CC}"
	else
		_emake -C util/cbmem
	fi
	if is_x86; then
		_emake -C util/ifdtool
		if use cros_host; then
			_emake -C util/amdfwtool
		else
			_emake -C util/superiotool \
				CONFIG_PCI=$(usex pci)
			_emake -C util/inteltool
			_emake -C util/nvramtool
		fi
	fi
}

src_install() {
	dobin util/cbfstool/cbfstool
	dobin util/cbfstool/elogtool
	if use cros_host; then
		dobin util/cbfstool/fmaptool
		dobin util/cbfstool/cbfs-compression-tool
		dobin util/archive/archive
	else
		dobin util/cbmem/cbmem
	fi
	if is_x86; then
		dobin util/ifdtool/ifdtool
		if use cros_host; then
			dobin util/amdfwtool/amdfwread
		else
			dobin util/superiotool/superiotool
			dobin util/inteltool/inteltool
			dobin util/nvramtool/nvramtool
		fi
		if use mma; then
			dobin util/mma/mma_setup_test.sh
			dobin util/mma/mma_get_result.sh
			dobin util/mma/mma_automated_test.sh
			insinto /etc/init
			doins util/mma/mma.conf
		fi
	fi
}
