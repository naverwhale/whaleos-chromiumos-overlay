# Copyright 2010 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The ChromiumOS Authors <chromium-os-dev@chromium.org>
# Purpose: Set -DNDEBUG if the cros-debug USE flag is not defined.
#

if [[ -z "${_ECLASS_CROS_DEBUG}" ]]; then
_ECLASS_CROS_DEBUG=1

case ${EAPI:-0} in
[012345]) die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}" ;;
esac

inherit flag-o-matic

IUSE="cros-debug"

cros-debug-add-NDEBUG() {
	use cros-debug || append-cppflags -DNDEBUG
}

fi
