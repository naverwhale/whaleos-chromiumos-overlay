# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_PROJECT="chromiumos/platform/feature-management"
CROS_WORKON_LOCALNAME="platform/feature-management"

CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon

DESCRIPTION="Public Feature data"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/feature-management"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="feature_management feature_management_bsp"

# Only a DEPEND, since this package only install file needed for compiling
# libsegmentation.
DEPEND="
	feature_management? ( chromeos-base/feature-management-private:= )
	feature_management_bsp? ( chromeos-base/feature-management-bsp:= )
"

BDEPEND="
	dev-go/lucicfg
	dev-libs/protobuf
"

src_prepare() {
	if use feature_management; then
		# Install private starlak feature file, if any.
		find "${SYSROOT}/build/share/feature-management/private" -name "*.star" \
				-exec cp -t "${S}" {} \+ || die
		# Install device selection file if present.
		find "${SYSROOT}/build/share/feature-management/private" \
				-name "device_selection.textproto" \
				-exec cp -t "${S}/devices" {} \+ || die
		# Install device selection sample file if present.
		find "${SYSROOT}/build/share/feature-management/private" \
				-name "device_selection_sample.textproto" \
				-exec cp -t "${S}/devices_test" {} \+ || die
	fi
	default
}

src_compile() {
	emake V=1
}

src_install() {
	insinto "/usr/include/libsegmentation"
	doins "${S}/generated/libsegmentation_pb.h"
	doins "${S}/generated/libsegmentation_test_pb.h"
	insinto "/build/share/libsegmentation"
	doins -r "${S}/proto"
}
