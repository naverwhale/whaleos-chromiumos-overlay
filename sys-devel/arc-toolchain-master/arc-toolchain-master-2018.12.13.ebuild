# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android toolchain (compilers, linker, libraries, headers)."

# The source tarball contains files collected from the sources below.
#
#   # from ab/4842234
#   cheets_arm-target_files-4842234.zip
#   cheets_x86_64-target_files-4842234.zip
#
#   # from 'repo.prop' in cheets_x86_64-target_files-4842234.zip
#   platform/bionic                                                 ad5d1d002f7f67a154bae4f5ebc9bfb2a3e87fa4
#   platform/external/expat                                         9a9c9b09b900298549ecdbef960fd94c998065e7
#   platform/external/libcxx                                        d824acd9e1cdcb28ce90a2986189dd5787ce529c
#   platform/external/zlib                                          639de1e7d86efe4ba29801b5a1dea426d91886f9
#   platform/frameworks/native                                      daf7a8e8e391a71767cf0c3fe01881790a58e92b
#   platform/hardware/libhardware                                   6d5d9f6eac44d4759fef99e52e2893f41d553824
#   platform/prebuilts/clang/host/linux-x86                         7843f0ff0edaad2f75722ae3e615635cfc53d475
#   platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9  b8776e061d978d84fb13115534f7ecd985593d12
#   platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9   7ab6cc5bdf74712aa77c54bedf6222519747afe1
#   platform/prebuilts/ndk                                          a07f79b980c6299223b5275d51f1c6a03dc945f4
#   platform/system/core                                            ba79b319ac73f7cd7a61f916ab2d1fd4211e68bf
#
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3 GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 FDL-1.2 UoI-NCSA"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

S="${WORKDIR}"
INSTALL_DIR="/opt/android-master"


# These prebuilts are already properly stripped.
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dodir "${INSTALL_DIR}"
	cp -pPR * "${D}/${INSTALL_DIR}/" || die
}
