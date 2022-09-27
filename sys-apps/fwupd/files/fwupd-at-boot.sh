#!/bin/bash
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# We block the UI at splash screen to check for available firmware
# updates and apply them. This script is called by `pre-ui` upstart job.

LOGGER_TAG="fwupd-at-boot"

main() {
  local ret=0

  if [ "$#" -ne 0 ]; then
    logger -t "${LOGGER_TAG}" "Too many arguments."
    return 1
  fi

  local pending
  readarray -d $'\0' pending < \
    <(find /var/lib/fwupd/pending -type f -size -100c -print0 2>/dev/null)
  if [ -z "${pending[*]}" ]; then
	return "${ret}"
  fi

  # Show boot alert.
  chromeos-boot-alert update_fwupd_firmware

  local i
  # Give it time for enumeration to detect devices.
  for i in "${pending[@]}"; do
    local seconds=0
    local plugins
    plugins="$(cat "${i}")"

    local p
    for p in ${plugins}; do
      case "${p}" in
      # USB Peripherals
      "ccgx"|"synaptics_cxaudio"|"synaptics_mst"|"vli")
        seconds=2
        ;;
      "emmc")
        # Trigger mmc/block events to adjust ownership
        udevadm trigger --action=add --settle --subsystem-match=mmc --subsystem-match=block
        ;;
      # USB4/TBT Retimer
      "thunderbolt")
        udevadm trigger --action=add --settle --subsystem-match=platform
        sleep 20 # (crrev.com/c/2670719)
        break 3 # Don't consider other cases as this is max wait time
      esac
    done
    sleep "${seconds}"
  done

  for i in "${pending[@]}"; do
    # Trigger fwupdtool-update job, which blocks until the job completes.
    /sbin/initctl emit fwupdtool-update GUID="${i##*/}" \
      PLUGIN="$(cat "${i}")" AT_BOOT="true" || ret=1
    rm "${i}"
  done

  return "${ret}"
}

main "$@"
