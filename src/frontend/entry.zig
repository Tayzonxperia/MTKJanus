// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const print = std.debug.print;

const dev = @import("device");

pub fn main() !void
{  
    const x = try dev.flash.Emmc.Metadata.init("iosiuf");
    _ = x;

    print("Hello", .{});
}
