// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
// Derived from: https://github.com/shomykohai/penumbra/blob/main/core/src/core/storage/emmc.rs
// Derived from: https://github.com/shomykohai/penumbra/blob/main/core/src/core/storage/ufs.rs
const root = @This();
const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;
const readInt = mem.readInt;



const UNKNOWN_PROTOCOL_ID: u8       = 0x000;
const EMMC_PROTOCOL_ID: u8          = 0x001;
const UFS_PROTOCOL_ID: u8           = 0x030;
const RPMB_FRAME_DATA_SIZE: usize   = 0x100;

/// A enum representing the flash memory kind.
pub const Kind = enum
{
    unknown,
    emmc,
    ufs,

    /// Returns the enum as a slice value
    pub fn toSlice(self: @This()) []const u8 {
        return switch (self) {
            .unknown    => "unknown",
            .emmc       => "emmc",
            .ufs        => "ufs", 
        };
    }

    /// Returns the enum as a integer value/protocol ID
    pub fn toInteger(self: @This()) u8 {
        return switch (self) {
            .unknown    => UNKNOWN_PROTOCOL_ID,
            .emmc       => EMMC_PROTOCOL_ID,
            .ufs        => UFS_PROTOCOL_ID,
        };
    }
};

/// A tagged union representing the flash memory metadata.
pub const Metadata = union(enum)
{
    pub const Error = error {
        ResponseTooLong,
        ResponseTooShort,
    };

    none:   void,
    emmc:   Emmc.Metadata,
    ufs:    Ufs.Metadata,

    pub fn kind(self: @This()) Kind {
        return switch (self) {
            .none   => .unknown,
            .emmc   => .emmc,
            .ufs    => .ufs
        };
    }
};

/// A tagged union representing the flash memory partition.
pub const Partition = union(enum)
{
    none:   void,
    emmc:   Emmc.Partition,
    ufs:    Ufs.Partition,

    pub fn kind(self: @This()) Kind {
        return switch (self) {
            .none   => .unknown,
            .emmc   => .emmc,
            .ufs    => .ufs
        };
    }
};

/// A struct representing flash memory of eMMC kind
pub const Emmc = struct 
{
    pub const Metadata = struct {
        /// Size of the boot1 partition in bytes
        boot1_size:     u64,
        /// Size of the boot2 partition in bytes
        boot2_size:     u64,    
        /// Size of the rpmb partition in bytes
        rpmb_size:      u64,
        /// Size of the gp1 partition in bytes
        gp1_size:       u64,
        /// Size of the gp2 partition in bytes
        gp2_size:       u64,
        /// Size of the gp3 partition in bytes
        gp3_size:       u64,
        /// Size of the gp4 partition in bytes
        gp4_size:       u64,
        /// Size of the user partition in bytes
        user_size:      u64,
        /// Firmware version of the flash
        firmware_ver:   u64,

        /// Kind of eMMC flash (e.g: eMMC or SDMMC)
        kind_id:        u32,
        /// Block size in bytes (usually 512)
        block_size:     u32,

        /// CID (Card ID) of the eMMC flash
        cid:            [16]u8,

        /// Returns the struct initzalized, or a error
        pub fn init(data: []const u8) root.Metadata.Error!@This() {
            if (data.len < 96) { return .ResponseTooShort; }

            return .{
                .boot1_size = readInt(u64, data[8..16], .little),
                .boot2_size = readInt(u64, data[16..24], .little),
                .rpmb_size = readInt(u64, data[24..32], .little),
                .gp1_size = readInt(u64, data[32..40], .little),
                .gp2_size = readInt(u64, data[40..48], .little),
                .gp3_size = readInt(u64, data[48..56], .little),
                .gp4_size = readInt(u64, data[56..64], .little),
                .user_size = readInt(u64, data[64..72], .little),
                .firmware_ver = readInt(u64, data[88..96], .little),

                .kind_id = readInt(u32, data[0..4], .little),
                .block_size = readInt(u32, data[4..8], .little),

                .cid = data[72..88][0..16].*,
            };
        }

        pub fn totalSize(self: @This()) u64 {
            return self.boot1_size + self.boot2_size + self.rpmb_size + self.gp1_size
            + self.gp2_size + self.gp3_size + self.gp4_size + self.user_size;
        }

        pub fn blockSize(self: @This()) u32 
        { return self.block_size; }
    };

    /// A struct representing a flash memory partition of eMMC kind
    pub const Partition = enum(u8) {
        /// A sentinel for a invalid/unknown partition
        unknown         = 0,
        /// The preloader partition
        boot1           = 1,    
        /// The preloader backup partition
        boot2           = 2,          
        /// The replay protected memory block partition
        rpmb            = 3,   
        /// The general purpose 1 partition
        gp1             = 4,
        /// The general purpose 2 partition
        gp2             = 5,    
        /// The general purpose 3 partition
        gp3             = 6,
        /// The general purpose 4 partition
        gp4             = 7,
        /// The userdata partition
        user            = 8,
        /// Represents the `boot1` and `boot2` partition together
        bothpreloader   = 9,

        pub fn toSlice(self: @This()) []const u8 {
            return switch (self) {
                .unknown        => "emmc:unknown",
                .boot1          => "emmc:boot1",
                .boot2          => "emmc:boot2",
                .rpmb           => "emmc:rpmb",
                .gp1            => "emmc:gp1",
                .gp2            => "emmc:gp2",
                .gp3            => "emmc:gp3",
                .gp4            => "emmc:gp4",
                .user           => "emmc:user",
                .bothpreloader  => "emmc:bothpreloader",
            };
        }

        /// Returns the region where the main preloader is stored
        pub fn getPreloaderMain() @This()
        { return .boot1; }

        /// Returns the region where the backup preloader is stored
        pub fn getPreloaderBackup() @This()
        { return .boot2; }

        /// Returns the region where the rpmb is stored
        pub fn getRpmb() @This()
        { return .rpmb; }

        /// Returns the region at the index where the general data is stored
        pub fn getGeneral(idx: u8) @This() {
            return switch (idx) {
                1   => .gp1,
                2   => .gp2,
                3   => .gp3,
                4   => .gp4,
                _   => .unknown,
            };
        }

        /// Returns the region where the userdata is stored
        pub fn getUserdata() @This()
        { return .user; }
    };
};

/// A struct representing flash memory of UFS kind
pub const Ufs = struct 
{
    pub const Metadata = struct {
        /// Size of the lu0 partition in bytes
        lu0_size:       u64,
        /// Size of the lu1 partition in bytes
        lu1_size:       u64,
        /// Size of the lu2 partition in bytes
        lu2_size:       u64,
        /// Size of the lu3 partition in bytes
        lu3_size:       u64,
        /// Size of the lu4 partition in bytes
        lu4_size:       u64,
        /// Size of the lu5 partition in bytes
        lu5_size:       u64,
        /// Size of the lu6 partition in bytes
        lu6_size:       u64,
        /// Size of the lu7 partition in bytes
        lu7_size:       u64,

        /// Kind of flash
        kind_id:        u32,
        /// Block size in bytes (usually 512)
        block_size:     u32,
 
        /// CID of the flash
        cid:            [16]u8,
        /// Serial number of the flash
        serial_num:     [12]u8,
        /// Firmware version of the flash storage
        firmware_ver:   [4]u8,

        /// Returns the struct initzalized, or a error
        pub fn init(data: []const u8) root.Metadata.Error!@This() {
            if (data.len < 168) { return .ResponseTooShort; }

            return .{
                .lu0_size = readInt(u64, data[8..16], .little),
                .lu1_size = readInt(u64, data[16..24], .little),
                .lu2_size = readInt(u64, data[24..32], .little),
                .lu3_size = 0,  // Thanks MTK babycakes <3
                .lu4_size = 0,  // Any code viewer, if you are wondering why   
                .lu5_size = 0,  // these are all 0, well MTK made it so most
                .lu6_size = 0,  // BROM/Preloader implmentations don't expose
                .lu7_size = 0,  // these partition sizes... we won't attempt 
                // trying to obtain these sizes yet, could be added later maybe >:3

                .kind_id = readInt(u32, data[0..4], .little),
                .block_size = readInt(u32, data[4..8], .little),

                .cid = data[24..40][0..16].*,
                .serial_num = data[70..82][0..12].*,
                .firmware_ver = data[56..60][0..4].*,
            };
        }

        pub fn totalSize(self: @This()) u64 {
            return self.lu0_size + self.lu1_size + self.lu2_size + self.lu3_size
            + self.lu4_size + self.lu5_size + self.lu6_size + self.lu7_size;
        }

        pub fn blockSize(self: @This()) u32 
        { return self.block_size; }
    };

    /// A enum representing a flash memory partition of UFS kind
    pub const Partition = enum(u8) {
        /// A sentinel for a invalid/unknown partition
        unknown         = 0,
        /// The preloader partition
        lu0             = 1,    
        /// The preloader backup partition
        lu1             = 2,          
        /// The userdata partition
        lu2             = 3,   
        /// The replay protected memory block partition
        lu3             = 4,
        /// The general purpose 1 partition
        lu4             = 5,    
        /// The general purpose 2 partition
        lu5             = 6,
        /// The general purpose 3 partition
        lu6             = 7,
        /// The general purpose 4 partition
        lu7             = 8,
        /// Represents the `lu0` and `lu1` partition together
        bothpreloader   = 9,

        pub fn toSlice(self: @This()) []const u8 {
            return switch (self) {
                .unknown        => "ufs:unknown",
                .lu0            => "ufs:lu0",
                .lu1            => "ufs:lu1",
                .lu2            => "ufs:lu2",
                .lu3            => "ufs:lu3",
                .lu4            => "ufs:lu4",
                .lu5            => "ufs:lu5",
                .lu6            => "ufs:lu6",
                .lu7            => "ufs:lu7",
                .bothpreloader  => "ufs:bothpreloader",
            };
        }

        /// Returns the region where the main preloader is stored
        pub fn getPreloaderMain() @This()
        { return .lu0; }

        /// Returns the region where the backup preloader is stored
        pub fn getPreloaderBackup() @This()
        { return .lu1; }

        /// Returns the region where the rpmb is stored
        pub fn getRpmb() @This()
        { return .lu3; }

        /// Returns the region at the index where the general data is stored
        pub fn getGeneral(idx: u8) @This() {
            return switch (idx) {
                1   => .lu4,
                2   => .lu5,
                3   => .lu6,
                4   => .lu7,
                _   => .unknown,
            };
        }

        /// Returns the region where the userdata is stored
        pub fn getUserdata() @This()
        { return .lu2; }
    };
};

pub const RpmbRegion = enum(u8)
{
    pub const Error = error 
    { RegionInvalid }; 

    unknown = 0,
    r1      = 1,
    r2      = 2,
    r3      = 3,
    r4      = 4,

    pub fn tryFrom(val: u8) @This() {
        return switch (val) {
            1 => .r1,
            2 => .r2,
            3 => .r3,
            4 => .r4,
            _ => .unknown,
        };
    }
};