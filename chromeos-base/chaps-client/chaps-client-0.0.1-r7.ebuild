# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="179a007713a28cc7e0ddbf53f1a8e620fd13de53"
CROS_WORKON_TREE=("d897a7a44e07236268904e1df7f983871c1e1258" "16b082e6f97c18dba42f68af125279be455ae1bc" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk chaps .gn"

PLATFORM_SUBDIR="chaps/client"

inherit cros-workon platform

DESCRIPTION="chaps D-Bus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/chaps/client/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies. We require the particular
# revision because libbrillo-0.0.1-r1 changed location of header files from
# chromeos/ to brillo/ and chromeos-dbus-bindings-0.0.1-r1058 generates the
# code using the new location.
DEPEND="
	cros_host? ( >=chromeos-base/chromeos-dbus-bindings-0.0.1-r1058 )
	chromeos-base/libbrillo:=
"

RDEPEND="
	chromeos-base/libbrillo:=
"

src_install() {
	# Install D-Bus client library.
	platform_install_dbus_client_lib "chaps"
}
