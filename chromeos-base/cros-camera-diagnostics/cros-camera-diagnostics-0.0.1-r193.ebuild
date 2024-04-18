# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "1f22ae3a4502e0dc175469f0df6450948deffc72" "94e1b450cb9db023fca27e8889078ff36c1eac15" "f14a034a2f1490fbe098b88fae238497341d5ab0" "f7a3d73092dcec2f55cfbdaf263fbe773244cbd9" "072e9dbcd89463d14062dff6f27bbc4929b31b69" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "05a052ec9a484e721478c7bb3e5e8e76c4ddc016")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include camera/mojo camera/diagnostics common-mk mojo_service_manager"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/diagnostics"

inherit cros-camera cros-workon platform

DESCRIPTION="ChromeOS camera diagnostics service."

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/cros-camera-libs:=
	chromeos-base/mojo_service_manager:="

DEPEND="${RDEPEND}"
