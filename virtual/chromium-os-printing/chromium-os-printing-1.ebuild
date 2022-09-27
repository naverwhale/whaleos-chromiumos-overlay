# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="List of packages required for the Chromium OS Printing subsystem"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"

IUSE="internal postscript"

RDEPEND="
	chromeos-base/ippusb_bridge
	chromeos-base/lexmark-fax-pnh
	net-print/cups
	net-print/cups-filters
	net-print/dymo-cups-drivers
	net-print/epson-inkjet-printer-escpr
	net-print/starcupsdrv
	internal? ( net-print/konica-minolta-printing-license )
	internal? ( net-print/xerox-printing-license )
	internal? ( net-print/fuji-xerox-printing-license )
	postscript? ( net-print/hplip )
"
