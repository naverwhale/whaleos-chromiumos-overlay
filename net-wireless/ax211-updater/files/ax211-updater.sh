#!/bin/sh

# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

logit() {
  logger -t "update-ax211" "$@"
}

# Cleanup of the temporary workaround for b/281885024.
# TODO(b/292016666): completely remove this script in M130 once devices in the
# field have likely had a chance to run this script and delete the leftover
# files.
main() {
  local iwlwifi_skip_reboot='/var/lib/misc/iwlwifi_skip_reboot'
  if [ -f "${iwlwifi_skip_reboot}" ]; then
    # Clean the leftover file from the "double reboot" temporary workaround for
    # b/281885024.
    logit "Cleaning up iwlwifi forced reboot."
    rm "${iwlwifi_skip_reboot}"
  else
    logit "iwlwifi forced reboot already cleaned up."
  fi
}

main "$@"
