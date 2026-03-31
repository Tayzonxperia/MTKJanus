// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
// Derived from: https://github.com/shomykohai/penumbra/blob/main/core/src/core/chip.rs
const root = @This();
const std = @import("std");



const DEFAULT_UART_ADDR: u32    = 0x11002000;
const DEFAULT_WDT_ADDR: u32     = 0x00000000;
const DEFAULT_TZCC_ADDR: u32    = 0x10210000;
const DEFAULT_SEJ_ADDR: u32     = 0x1000A000;

/// A struct representing specs of a system-on-chip
pub const Specification = struct 
{
    /// The chip security engine JTAG address (e.g: `0x100A000`)
    sej_addr:   u32,
    /// The chip TrustZone clock controller address (e.g: `0x10210000`)
    tzcc_addr:  u32,

    /// The chip watchdog timer address (e.g: `0x10007000`)
    wdt_addr:   u32,
    /// The chip UART address (e.g: `0x11002000`)
    uart_addr:  u32,

    /// The chip hardware code (e.g: `0x279`)
    hw_code:    u16,
    /// The chip model name (e.g: `MTK6797`)
    name:       []const u8,
};

/// A struct holding the preknown database of MTK SOCs
pub const Database = struct 
{   
    /// Makes a MTK SOC database entry
    fn make(
        sej_addr: ?u32,
        tzcc_addr: ?u32,
        wdt_addr: ?u32, 
        uart_addr: ?u32, 
        hw_code: u16,
        name: []const u8
    ) Specification {
        return .{
            .sej_addr = sej_addr orelse DEFAULT_SEJ_ADDR,
            .tzcc_addr = tzcc_addr orelse DEFAULT_TZCC_ADDR,
            .wdt_addr = wdt_addr orelse DEFAULT_WDT_ADDR,
            .uart_addr = uart_addr orelse DEFAULT_UART_ADDR,
            .hw_code = hw_code,
            .name = name,
        };
    }

    /// The default, uses commonly known addresses
    /// to aim for compatibility, useful for testing
    pub const UNKNOWN = make(
        null,
        null,
        null,
        null,
        0x00000000,
        "unknown"
    );
    
    pub const MT6797 = make(
        null,
        null,
        0x10007000,
        null,
        0x279,
        "Helio X25"
    );

    pub const MT6755 = make(
        null,
        null,
        0x10007000,
        null,
        0x326,
        "Helio P10"
    );

    pub const MT6757 = make(
        null,
        null,
        0x10007000,
        null,
        0x551,
        "Helio P20"
    );

    pub const MT6799 = make(
        null,
        0x11B20000,
        0x10211000,
        null,
        0x562,
        "Helio X30"
    );

    pub const MT6750_1 = make(
        null,
        null,
        0x10007000,
        null,
        0x601,
        "none"
    );

    pub const MT6750_2 = make(
        null,
        null,
        0x10007000,
        null,
        0x633,
        "MT8321"
    );

    pub const MT6758 = make(
        0x10080000,
        0x11240000,
        0x10211000,
        0x10211000,
        0x688,
        "Helio P30"
    );

    pub const MT6763 = make(
        null,
        null,
        0x10211000,
        null,
        0x690,
        "Helio P23"
    );

    pub const MT6739 = make(
        null,
        null,
        0x10007000,
        null,
        0x699,
        "MT8765"
    );

    pub const MT6768 = make(
        null,
        null,
        0x10007000,
        null,
        0x707,
        "Helio G85"
    );

    pub const MT6761 = make(
        null,
        null,
        0x10007000,
        null,
        0x717,
        "Helio P22"
    );
};