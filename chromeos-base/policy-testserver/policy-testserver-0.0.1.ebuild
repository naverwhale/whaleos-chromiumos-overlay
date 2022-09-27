# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit cros-constants git-r3 python-any-r1

# Every 3 strings in this array indicates a repository to checkout:
#   - A unique name (to avoid checkout conflits)
#   - The repository URL
#   - The commit to checkout
EGIT_REPO_URIS=(
	"third_party/tlslite"
	"${CROS_GIT_HOST_URL}/chromium/src/third_party/tlslite.git"
	"4b50b6b2c03869fbdbe03eb1ece5a23a2ded99cc"

	"net/tools/testserver"
	"${CROS_GIT_HOST_URL}/chromium/src/net/tools/testserver.git"
	"1e3338b724b0a36fc453901ca8846bd0d406d988"

	"components/policy"
	"${CROS_GIT_HOST_URL}/chromium/src/components/policy.git"
	"32d024b3f87c660b931f82dc7c45252cef54d2ee"

	# private_membership and shell_encryption are not used in Chrome OS at
	# the moment. They are just required to compile the proto files. An
	# uprev will only be necessary if the respective proto files change.
	"private_membership"
	"${CROS_GIT_HOST_URL}/chromium/src/third_party/private_membership.git"
	"fa5d439ccfcb5813ef9d5aa7b66299e6d24a62da"

	"shell_encryption"
	"${CROS_GIT_HOST_URL}/chromium/src/third_party/shell-encryption.git"
	"4b66a57bf81ff88fb94113426f2f4ffbbd66cb95"
)

DESCRIPTION="Dependencies needed by the policy_testserver"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

POLICY_DIR="${S}/components/policy"

PRIVATE_MEMBERSHIP_DIR="${S}/private_membership/src"
SHELL_ENCRYPTION_DIR="${S}/shell_encryption/src"

# Destination on DUT is /usr/local/share/policy_testserver.
TESTSERVER_DIR="/usr/share/policy_testserver"

DEPEND="
	dev-libs/protobuf
"

RDEPEND="
	dev-python/protobuf-python
"


src_unpack() {
	# Unpack all chromium mirrored code.
	set -- "${EGIT_REPO_URIS[@]}"
	while [[ $# -gt 0 ]]; do
		EGIT_CHECKOUT_DIR="${S}/$1" \
			EGIT_REPO_URI=$2 \
			EGIT_COMMIT=$3 \
			git-r3_src_unpack
		shift 3
	done
}

src_compile() {
	# Generate cloud_policy.proto with --all-chrome-versions option.
	"${POLICY_DIR}/tools/generate_policy_source.py" \
		--cloud-policy-protobuf="${WORKDIR}/cloud_policy.proto" \
		--all-chrome-versions \
		--target-platform="chrome_os" \
		--policy-templates-file="${POLICY_DIR}/resources/policy_templates.json" \
		|| die

	# Create Python bindings needed for policy_testserver.py.
	protoc --proto_path="${POLICY_DIR}/proto" \
		--proto_path="${PRIVATE_MEMBERSHIP_DIR}"\
		--proto_path="${SHELL_ENCRYPTION_DIR}"\
		--python_out="${WORKDIR}" \
		"${POLICY_DIR}/proto/chrome_device_policy.proto" \
		"${POLICY_DIR}/proto/device_management_backend.proto" \
		"${POLICY_DIR}/proto/chrome_extension_policy.proto" \
		"${POLICY_DIR}/proto/policy_common_definitions.proto" \
		"${PRIVATE_MEMBERSHIP_DIR}/private_membership_rlwe.proto" \
		"${PRIVATE_MEMBERSHIP_DIR}/private_membership.proto" \
		"${SHELL_ENCRYPTION_DIR}/serialization.proto" \
		|| die
	protoc --proto_path="${WORKDIR}" --proto_path="${POLICY_DIR}/proto" \
		--python_out="${WORKDIR}" \
		"${WORKDIR}/cloud_policy.proto" \
		|| die
}

src_install() {
	insinto "${TESTSERVER_DIR}"
	doins -r "${S}"/third_party/tlslite
	doins -r "${S}"/net/tools/testserver
	doins -r "${S}"/components/policy/test_support/asn1der.py
	doins -r "${S}"/components/policy/test_support/policy_testserver.py

	insinto "${TESTSERVER_DIR}/proto_bindings"
	doins "${WORKDIR}/chrome_device_policy_pb2.py"
	doins "${WORKDIR}/device_management_backend_pb2.py"
	doins "${WORKDIR}/chrome_extension_policy_pb2.py"
	doins "${WORKDIR}/policy_common_definitions_pb2.py"
	doins "${WORKDIR}/cloud_policy_pb2.py"
	doins "${WORKDIR}/private_membership_rlwe_pb2.py"
	doins "${WORKDIR}/private_membership_pb2.py"
	doins "${WORKDIR}/serialization_pb2.py"
}
