# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# TODO(b/296938456): Delete this file after all usages are switched to
# cros-kernel.eclass.

if [[ -z "${_ECLASS_CROS_KERNEL2}" ]]; then
_ECLASS_CROS_KERNEL2=1

# cros-kernel2 is just an alias to cros-kernel.
inherit cros-kernel
cros-kernel2_pkg_setup() {
	cros-kernel_pkg_setup
}
cros-kernel2_src_unpack() {
	cros-kernel_src_unpack
}
cros-kernel2_src_prepare() {
	cros-kernel_src_prepare
}
cros-kernel2_src_configure() {
	cros-kernel_src_configure
}
cros-kernel2_src_compile() {
	cros-kernel_src_compile
}
cros-kernel2_src_install() {
	cros-kernel_src_install "$@"
}

fi  # _ECLASS_CROS_KERNEL2

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install
