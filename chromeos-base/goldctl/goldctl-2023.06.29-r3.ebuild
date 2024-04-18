# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# When the time comes to roll to a new version, run the following for each architecture:
# $ cipd resolve skia/tools/goldctl/linux-${ARCH} -version latest
# Latest as of 2021-06-29
SRC_URI="
	amd64? ( cipd://skia/tools/goldctl/linux-amd64:vXHLgx-NDpLedjYw8l4Oet94N2EuXVFRqF9RcxWV6gMC  -> ${P}-amd64.zip )
	x86?   ( cipd://skia/tools/goldctl/linux-386:34ixNU9kvf31PFIdI1tJpaFKTNLoXxYEGEIg54zXsdYC    -> ${P}-x86.zip )
	arm64? ( cipd://skia/tools/goldctl/linux-arm64:rdEhDdkkHZ_XdF4emC1oHxXuYaWIrx26s7Mjyoxh3UYC  -> ${P}-arm64.zip )
	arm?   ( cipd://skia/tools/goldctl/linux-armv6l:08YRn4elrPxUCeQYvWbzCjNHhOSNfa-2J8ZCHJtJYM8C -> ${P}-arm.zip )
"

DESCRIPTION="This command-line tool lets clients upload images to gold"
HOMEPAGE="https://skia.googlesource.com/buildbot/+/HEAD/gold-client/"
RESTRICT="mirror"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

BDEPEND="app-arch/unzip"

src_install() {
	if [[ ! -e "goldctl" ]]; then
		cat > "goldctl" <<EOF
#!/bin/sh

echo "Goldctl binary is not supported on the architecture ${ARCH}." >&2
exit 1

EOF
	fi
	dobin goldctl
}
