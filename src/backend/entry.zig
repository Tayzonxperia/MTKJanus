// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const print = std.debug.print;

const mem = std.mem;
const heap = std.heap;


const Device = @import("Device");
const chip = Device.chip;
const flash = Device.flash;
const gpt = Device.gpt;
pub const driver = Device.driver;



fn generate_debug_flash_data() [96]u8 {
    var buf: [96]u8 = [_]u8{0} ** 96;

    // kind_id + block_size
    mem.writeInt(u32, buf[0..4], 0x1234, .little);
    mem.writeInt(u32, buf[4..8], 512, .little);

    // sizes
    mem.writeInt(u64, buf[8..16],  0x1000, .little); // boot1
    mem.writeInt(u64, buf[16..24], 0x1000, .little); // boot2
    mem.writeInt(u64, buf[24..32], 0x2000, .little); // rpmb
    mem.writeInt(u64, buf[32..40], 0x3000, .little); // gp1
    mem.writeInt(u64, buf[40..48], 0x4000, .little); // gp2
    mem.writeInt(u64, buf[48..56], 0x5000, .little); // gp3
    mem.writeInt(u64, buf[56..64], 0x6000, .little); // gp4
    mem.writeInt(u64, buf[64..72], 0x7000, .little); // user

    // CID
    for (buf[72..88], 0..) |*b, i| {
        b.* = @intCast(i);
    }

    // firmware
    mem.writeInt(u64, buf[88..96], 0xAA32234312443, .little);

    return buf;
}

fn init_flash(
    allocator: mem.Allocator,
    data: []const u8,
) !driver.Flash {
    const meta = try flash.Emmc.Metadata.init(data);

    var parts = try allocator.alloc(driver.Flash.Partition, 8);

    parts[0] = .{
        .name = "boot1",
        .size = meta.boot1_size,
        .addr = 0,
        .part = .{ .emmc = .boot1 },
    };

    parts[1] = .{
        .name = "boot2",
        .size = meta.boot2_size,
        .addr = meta.boot1_size,
        .part = .{ .emmc = .boot2 },
    };

    parts[2] = .{
        .name = "rpmb",
        .size = meta.rpmb_size,
        .addr = meta.boot1_size + meta.boot2_size,
        .part = .{ .emmc = .rpmb },
    };

    // (you can expand for gp1..gp4, user, etc)

    return driver.Flash{
        .kind = .emmc,
        .metadata = .{
            .preloader_main_size   = meta.boot1_size,
            .preloader_backup_size = meta.boot2_size,
            .rpmb_size            = meta.rpmb_size,
            .userdata_size         = meta.user_size,
            .general1_size         = meta.gp1_size,
            .general2_size         = meta.gp2_size,
            .general3_size         = meta.gp3_size,
            .general4_size         = meta.gp4_size,
            .firmware_ver          = meta.firmware_ver,
            .kind_id               = meta.kind_id,
            .block_size            = meta.block_size,
            .card_id            = meta.cid,
            .serial_num        = null,
        },
        .partitions = parts,
    };
}

export fn testing() void
{
    _ = chip;
    _ = flash;
    _ = driver;


    const allocator = heap.c_allocator;

    const flashData = generate_debug_flash_data();

    const flashObject = init_flash(allocator, &flashData) catch @panic("FLASH INIT FAILED");

    print(
    \\  [ FLASH ] Infomation:
    \\
    \\ ==>  Firmware version: {x}
    \\ ==>  Card ID: {x}
    \\ ==>  Kind ID: {x}
    \\ ==>  Block size: {d}
    \\
    , .{
        flashObject.metadata.firmware_ver,
        flashObject.metadata.card_id,
        flashObject.metadata.kind_id,
        flashObject.metadata.block_size
        }
    );
}


export fn __init__() linksection(".init_array") void
{
}

export fn __fini__() linksection(".fini_array") void
{
}