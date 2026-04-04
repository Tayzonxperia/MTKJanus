// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const print = std.debug.print;



extern fn testing() void;
pub fn main() !void
{
    testing();
}
