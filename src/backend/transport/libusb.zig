// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const root = @This();
const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;

const binding = @cImport(@cInclude("libusb-1.0/libusb.h"));




binding.