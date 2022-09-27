# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="6c9fd34b4a6231efc189c530e2f05d908b55185e"
CROS_WORKON_TREE="7d7b27a37be2e8e137560ee23d3113d018235a2d"
CROS_WORKON_PROJECT="chromiumos/platform/inputcontrol"
CROS_WORKON_LOCALNAME="platform/inputcontrol"

inherit cros-workon

DESCRIPTION="A collection of utilities for configuring input devices"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/inputcontrol/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

RDEPEND="app-arch/gzip"
DEPEND=""
