# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ebuild for Android toolchain (compilers, linker, libraries, headers)."

# The source tarball contains files collected from the sources below.
#
#   # from ab/5573022
#   cheets_arm-target_files-5573022.zip
#   cheets_x86_64-target_files-5573022.zip
#
#   # from 'repo.prop' on ab/5573022 (cheets_x86_64)
#   platform/bionic                                                 7a0773b9937b60ce2fbac00eb4d963787de46414
#   platform/external/expat                                         3c8c2304206e5e6f917b3919bea9d10ea37830a0
#   platform/external/libcxx                                        5e13edc6255e124c25ac126d38fcb5166c9d51b8
#   platform/external/libcxxabi                                     8b1c8fa9a979f970ee0815e41cddaa0b8e4759f3
#   platform/external/zlib                                          7a2144a25d88ad9079371c1c8cf70614dcc95ac6
#   platform/frameworks/native                                      802cb1261b42c8a5edc360d61ecdf1379f354e8d
#   platform/hardware/libhardware                                   c5e1f4310e076870b562fec255e2a1b5c2d8d1b5
#   platform/prebuilts/clang/host/linux-x86                         bb984e2da04817d8aea7a408903bab6573884107
#   platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9  33af90b1d82043484654cabd912cab99e9913e1b
#   platform/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9   679aefae75c1d7dcc72e2d6ccc1976881aa02eec
#   platform/prebuilts/ndk                                          7602a59fae84a55e87f3b616c4730b643ea70690
#   platform/system/core                                            f9eb6bfed12c419bcbef75a75066f98a33086365
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
