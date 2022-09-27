# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Honor the imports from the proto files + our own prefix.
CROS_GO_PACKAGES=(
	"android.com/frameworks/..."
)

inherit cros-go

DESCRIPTION="AOSP frameworks/base protobuf files"
HOMEPAGE="https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android11-dev/core/proto/"
GIT_COMMIT="c29468777021f4970ab20b38601448fe81ecdcbb"
SRC_URI="https://android.googlesource.com/platform/frameworks/base/+archive/${GIT_COMMIT}/core/proto.tar.gz -> aosp-frameworks-base-core-proto-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

DEPEND="${RDEPEND}
	dev-go/protobuf
	dev-libs/protobuf:=
"

S=${WORKDIR}

src_unpack() {
	# Unpack the tar.gz files manually since they need to be unpacked in special directories.

	mkdir -p frameworks/base/core/proto || die

	pushd . || die
	cd frameworks/base/core/proto || die
	unpack "aosp-frameworks-base-core-proto-${PV}.tar.gz"
	popd || die
}

src_compile() {
	# SRC_URI contains all .proto files from Android frameworks/base (~150 .proto files).
	# For Tast, we only need a subset: Activity Manager,  Window Manager,
	# and its dependencies.
	# If there is a need to add more, add a new "protoc" or extend an
	# existing one.

	local core_path="frameworks/base/core/proto/android"
	local cp="${WORKDIR}/${core_path}"
	local out="${WORKDIR}/gen/go/src/android.com"

	# protoc allow us to map a "protobuf import" with a "golang import".
	# This is the list of protobuf import files that need to get remapped
	# to use the "android.com" prefix. Basically all the generated golang
	# files must use the "android.com" import prefix.
	local imports_to_remap=(
		"${core_path}/app/activitymanager.proto"
		"${core_path}/app/appexit_enums.proto"
		"${core_path}/app/appexitinfo.proto"
		"${core_path}/app/enums.proto"
		"${core_path}/app/notification.proto"
		"${core_path}/app/profilerinfo.proto"
		"${core_path}/app/statusbarmanager.proto"
		"${core_path}/app/window_configuration.proto"
		"${core_path}/content/activityinfo.proto"
		"${core_path}/content/component_name.proto"
		"${core_path}/content/configuration.proto"
		"${core_path}/content/intent.proto"
		"${core_path}/content/locale.proto"
		"${core_path}/content/package_item_info.proto"
		"${core_path}/graphics/pixelformat.proto"
		"${core_path}/graphics/point.proto"
		"${core_path}/graphics/rect.proto"
		"${core_path}/internal/processstats.proto"
		"${core_path}/os/bundle.proto"
		"${core_path}/os/looper.proto"
		"${core_path}/os/message.proto"
		"${core_path}/os/messagequeue.proto"
		"${core_path}/os/patternmatcher.proto"
		"${core_path}/os/powermanager.proto"
		"${core_path}/privacy.proto"
		"${core_path}/server/activitymanagerservice.proto"
		"${core_path}/server/animationadapter.proto"
		"${core_path}/server/intentresolver.proto"
		"${core_path}/server/surfaceanimator.proto"
		"${core_path}/server/windowcontainerthumbnail.proto"
		"${core_path}/server/windowmanagerservice.proto"
		"${core_path}/util/common.proto"
		"${core_path}/view/display.proto"
		"${core_path}/view/displaycutout.proto"
		"${core_path}/view/displayinfo.proto"
		"${core_path}/view/enums.proto"
		"${core_path}/view/remote_animation_target.proto"
		"${core_path}/view/surface.proto"
		"${core_path}/view/surfacecontrol.proto"
		"${core_path}/view/windowlayoutparams.proto"
	)

	# Generates the mapping between protobuf import file to Go import. E.g:
	# Mframeworks/core/display.proto=android.com/frameworks/core
	local map=""
	for fp in "${imports_to_remap[@]}"; do
		map="${map},M${fp}=android.com/${fp%/*}"
	done


	mkdir -p "${out}" || die
	# One "protoc" invocation per directory, otherwise it will create
	# package conflicts.
	# Use a different "import_path" per directory to avoid name conflict.
	protoc \
		--go_out="${map},import_path=android.com/${core_path}:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/privacy.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/app:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/app/activitymanager.proto" \
		"${cp}/app/appexit_enums.proto" \
		"${cp}/app/appexitinfo.proto" \
		"${cp}/app/enums.proto" \
		"${cp}/app/notification.proto" \
		"${cp}/app/profilerinfo.proto" \
		"${cp}/app/statusbarmanager.proto" \
		"${cp}/app/window_configuration.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/content:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/content/activityinfo.proto" \
		"${cp}/content/component_name.proto" \
		"${cp}/content/configuration.proto" \
		"${cp}/content/intent.proto" \
		"${cp}/content/locale.proto" \
		"${cp}/content/package_item_info.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/graphics:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/graphics/pixelformat.proto" \
		"${cp}/graphics/point.proto" \
		"${cp}/graphics/rect.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/internal:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/internal/processstats.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/os:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/os/bundle.proto" \
		"${cp}/os/looper.proto" \
		"${cp}/os/message.proto" \
		"${cp}/os/messagequeue.proto" \
		"${cp}/os/patternmatcher.proto" \
		"${cp}/os/powermanager.proto" \
		"${cp}/os/worksource.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/server:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/server/activitymanagerservice.proto" \
		"${cp}/server/animationadapter.proto" \
		"${cp}/server/intentresolver.proto" \
		"${cp}/server/surfaceanimator.proto" \
		"${cp}/server/windowcontainerthumbnail.proto" \
		"${cp}/server/windowmanagerservice.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/util:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/util/common.proto" \
		|| die

	protoc \
		--go_out="${map},import_path=android.com/${core_path}/view:${out}" \
		--proto_path="${WORKDIR}" \
		"${cp}/view/display.proto" \
		"${cp}/view/displaycutout.proto" \
		"${cp}/view/displayinfo.proto" \
		"${cp}/view/enums.proto" \
		"${cp}/view/remote_animation_target.proto" \
		"${cp}/view/surface.proto" \
		"${cp}/view/surfacecontrol.proto" \
		"${cp}/view/windowlayoutparams.proto" \
		|| die

	CROS_GO_WORKSPACE="${WORKDIR}/gen/go/"
}
