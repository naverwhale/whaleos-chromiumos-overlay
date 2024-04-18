#!/usr/bin/env python3
# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Wrapper of pkg-config command line to format output for bazel.

Parses the pkg-config output and format it into BUILD.bazel,
so that it can be used in BUILD.bazel files easily.

Usage:
  pkg-config-to-bazel <pkg-config> args ...

Specifically, this script does not expect any additional flags.
"""

import json
import shlex
import subprocess
import sys


def get_shell_output(cmd):
    """Run |cmd| and return output as a list."""
    result = subprocess.run(
        cmd, encoding="utf-8", stdout=subprocess.PIPE, check=False
    )
    if result.returncode:
        sys.exit(result.returncode)
    return shlex.split(result.stdout)


def main(argv):
    if len(argv) < 2:
        sys.exit(f"Usage: {sys.argv[0]} <pkg-config> <modules>")

    flags = get_shell_output(argv)
    if flags:
        print('"' + '", "'.join(flags) + '"')


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
