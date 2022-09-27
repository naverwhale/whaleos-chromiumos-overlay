# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google3 document scanning library."

IUSE="
	march_alderlake
	march_armv8
	march_bdver4
	march_corei7
	march_goldmont
	march_silvermont
	march_skylake
	march_tigerlake
	march_tremont
	march_znver1
	ondevice_document_scanner
"

SRC_URI="gs://chromeos-localmirror/distfiles/chromeos-document-scanning-lib-${PV}.tar.bz2"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	insinto /usr/include/chromeos/libdocumentscanner/
	doins document_scanner.h

	if ! use ondevice_document_scanner; then
		return
	fi

	local document_scanning_lib_path="/opt/google/chrome/ml_models/document_scanning/"

	insinto "${document_scanning_lib_path}"
	# Specified architecture use flag check should be put before amd64, arm, and
	# arm64.
	insopts -m0755
	if use march_alderlake; then
		newins "x86_64-alderlake/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_armv8; then
		newins "armv7-armv8-a+crc/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_bdver4; then
		newins "x86_64-bdver4/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_corei7; then
		newins "x86_64-corei7/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_goldmont; then
		newins "x86_64-goldmont/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_silvermont; then
		newins "x86_64-silvermont/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_skylake; then
		newins "x86_64-skylake/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_tigerlake; then
		newins "x86_64-tigerlake/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_tremont; then
		newins "x86_64-tremont/libdocumentscanner.so" "libdocumentscanner.so"
	elif use march_znver1; then
		newins "x86_64-znver1/libdocumentscanner.so" "libdocumentscanner.so"
	elif use amd64; then
		newins "x86_64/libdocumentscanner.so" "libdocumentscanner.so"
	elif use arm; then
		newins "armv7/libdocumentscanner.so" "libdocumentscanner.so"
	elif use arm64; then
		newins "arm/libdocumentscanner.so" "libdocumentscanner.so"
	fi
	insopts -m0644
}
