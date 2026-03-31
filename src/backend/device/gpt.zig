// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
// Derived from: https://github.com/shomykohai/penumbra/blob/main/core/src/core/storage/gpt.rs
const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;

const hash = std.hash;
const Crc32 = hash.Crc32;



const PART_SIGNATURE: [8]u8 = "EFI PART";

/// A error union for the GPT subsystem
pub const Error = error
{   
};

/// A enum representing the GPT table kind
pub const Kind = enum 
{
    unknown,
    pgpt,
    sgpt,

    /// Returns the enum as a slice value
    pub fn toSlice(self: @This()) []const u8 {
        return switch (self) {
            .unknown    => "unknown",
            .pgpt       => "pgpt",
            .sgpt       => "sgpt",
        };
    }
};

/// A struct representing the GPT header
pub const Header = struct 
{
    sector_size: u64,

    current_lba: u64,
    backup_lba: u64,
    first_usable_lba: u64,
    last_usable_lba: u64,
    part_entry_lba: u64,

    entry_num: u32,
    entry_size: u32,

    header_size: u32,
    header_crc32: u32,

    part_array_crc32: u32,
};