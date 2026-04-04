// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");

const flash = @import("flash.zig");
const gpt = @import("gpt.zig");



pub const Flash = struct 
{   
    kind:       flash.Kind,
    metadata:   Metadata,
    partitions: []Partition,

    pub const Metadata = struct {
        preloader_main_size:    u64,
        preloader_backup_size:  u64,
        rpmb_size:              ?u64,
        userdata_size:          u64,
        general1_size:          u64,
        general2_size:          u64,
        general3_size:          u64,
        general4_size:          u64,
        firmware_ver:           u64,

        kind_id:                u32,
        block_size:             u32,

        card_id:                [16]u8,
        serial_num:             ?[12]u8,
    };

    pub const Partition = struct {
        name:   []const u8,
        size:   u64,
        addr:   u64,
        part:   flash.Partition,
    };

    pub const Driver = struct {
        // The VTable would go here, etc etc...
    };
};