# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT=("ae07277fe7394cbb60e746d21d17f2f0a1ac163b" "55ec79ce4afc543a9e50b18a9a1f4fd00b81353d")
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "7eeb6f1068bd75e9a9a5269354df667792b986ea")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/redaction_tool"
)

CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/redaction_tool"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	# This needs to be platform2/redaction_tool instead of
	# platform/redaction_tool because we are using the
	# platform2 build system.
	"${S}/platform2/redaction_tool"
)

CROS_WORKON_SUBTREE=("common-mk metrics .gn" "")

PLATFORM_SUBDIR="redaction_tool"

inherit cros-workon platform

DESCRIPTION="Redaction tool library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/redaction_tool"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+cpp20"

COMMON_DEPEND="
	chromeos-base/metrics:=
	dev-libs/re2:=
"

RDEPEND="${COMMON_DEPEND}"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/session_manager-client
"

platform_pkg_test() {
	platform test_all
}
