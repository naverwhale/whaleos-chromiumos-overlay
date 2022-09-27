# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-credentials.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Set credentials properly to access private git repo.
# @DESCRIPTION:
# Copy in credentials to fake home directory so that build process can
# access vcs and ssh if needed.
# Add a call to cros-credentials_setup before accessing a private repo.

cros-credentials_setup() {
	einfo "Setting up CrOS credentials"
	mkdir -vp "${HOME}"
	local whoami=$(whoami)
	local ssh_config_dir="/home/${whoami}/.ssh"
	if [[ -d "${ssh_config_dir}" ]]; then
		cp -vrfp "${ssh_config_dir}" "${HOME}" || die
	fi
	local net_config="/home/${whoami}/.netrc"
	if [[ -f "${net_config}" ]]; then
		einfo "Copying ${net_config} to ${HOME}"
		cp -vfp "${net_config}" "${HOME}" || die
	fi
	local gitcookies_src="/home/${whoami}/.gitcookies"
	local gitcookies_dst="${HOME}/.gitcookies"
	if [[ -f "${gitcookies_src}" ]]; then
		cp -vfp "${gitcookies_src}" "${gitcookies_dst}" || die
		echo 'gitcookies accounts:'
		awk 'NF && $1 !~ /^#/ {print $1}' "${gitcookies_dst}"
		git config --global http.cookiefile "${gitcookies_dst}"
	fi
	local luci_creds_src="/home/${whoami}/.config/chrome_infra/auth/creds.json"
	local luci_creds_dest="${HOME}/.config/chrome_infra/auth/"
	if [[ -f "${luci_creds_src}" ]]; then
		einfo "Copying ${luci_creds_src} to ${HOME}"
		mkdir -p "${luci_creds_dest}"
		cp -vfp "${luci_creds_src}" "${luci_creds_dest}" || die
	fi

	# Force disable user/pass prompting to avoid hanging builds.
	git config --global core.askPass true
}
