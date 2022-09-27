# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

PKG_CONFIG ?= pkg-config
PC_DEPS = dbus-1 libchrome libmojo libcras
PKG_CONFIG_CFLAGS := $(shell $(PKG_CONFIG) --cflags $(PC_DEPS))
PKG_CONFIG_LIBS := $(shell $(PKG_CONFIG) --libs $(PC_DEPS))

CXXFLAGS += -std=c++14
CPPFLAGS += $(PKG_CONFIG_CFLAGS)
LDFLAGS += -L .
LDLIBS = -lrtanalytics -ldl

rtanalytics_main: *.h *.cc
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) \
	main.cc cras_client_impl.cc shared_memory_provider.cc \
	receiver_impl.cc producer_impl.cc \
	video_capture_service_client_impl.cc mojo_connector.cc \
	connector.mojom.cc device_factory.mojom.cc geometry.mojom.cc \
	receiver.mojom.cc values.mojom.cc virtual_device.mojom.cc \
	constants.mojom.cc device.mojom.cc image_capture.mojom.cc \
	producer.mojom.cc time.mojom.cc video_capture_types.mojom.cc \
	mailbox_holder.mojom.cc mailbox.mojom.cc sync_token.mojom.cc \
	shared_memory.mojom.cc scoped_access_permission.mojom.cc \
	-o rtanalytics_main \
	$(PKG_CONFIG_LIBS) $(LDLIBS)

