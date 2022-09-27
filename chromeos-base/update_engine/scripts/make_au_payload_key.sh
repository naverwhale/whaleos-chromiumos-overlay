#!/bin/bash

# Copyright (c) 2021 NAVER Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Just picked up make_au_payload_key in
# platform/vboot_reference/scripts/keygeneration/common.sh
dir=$1
priv="${dir}/update_key.pem"
pub="${dir}/update-payload-key.pub.pem"
openssl genrsa -out "${priv}" 2048
openssl rsa -pubout -in "${priv}" -out "${pub}"

