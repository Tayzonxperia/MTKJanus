// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");

pub const chip = @import("chip.zig");
pub const flash = @import("flash.zig");
pub const driver = @import("driver.zig");

pub const ChipDriver = struct {
    ptr: *anyopaque,
};

pub const FlashDriver = struct {
    ptr: *anyopaque,
};

pub const FlashHandle = driver.Handle;
pub const FlashKind = flash.Kind;
