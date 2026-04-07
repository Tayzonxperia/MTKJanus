// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const builtin = @import("builtin");



pub inline fn memory_move(comptime T: type, dest: []T, src: []const T) void
{
    comptime if (builtin.link_libc) {
        _ = memmove(dest.ptr, src.ptr, src.len * @sizeOf(T));
    } else {
        @memmove(dest, src);
    };
}

pub inline fn memory_copy(comptime T: type, dest: []T, src: []const T) void
{
    comptime if (builtin.link_libc) {
        _ = memcpy(dest.ptr, src.ptr, src.len * @sizeOf(T));
    } else {
        @memcpy(dest[0..src.len], src);
    };
}



extern "c" fn memcpy(*anyopaque, *const anyopaque, usize) *anyopaque;
extern "c" fn memmove(*anyopaque, *const anyopaque, usize) *anyopaque;
