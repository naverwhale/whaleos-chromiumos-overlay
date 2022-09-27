# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

pkglib_LTLIBRARIES = imstdoutsock.la

imstdoutsock_la_SOURCES = imstdoutsock.c
imstdoutsock_la_CPPFLAGS = -I$(top_srcdir) $(PTHREADS_CFLAGS) $(RSRT_CFLAGS)
imstdoutsock_la_LDFLAGS = -module -avoid-version
imstdoutsock_la_LIBADD =
