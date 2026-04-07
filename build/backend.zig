// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");

const Build = std.Build;
const Step = Build.Step;

const common = @import("common.zig");
const OptionData = common.OptionData;
const createMod = common.createMod;
const configMod = common.configMod;



pub const PATH: []const u8     = "src/backend/";

pub const Modules = struct 
{
    binding:    *Build.Module,
    common:     *Build.Module,
    device:     *Build.Module,
    transport:  *Build.Module,

    pub fn init(b: *Build) @This() {
        const bindingMod = b.addModule("Binding", .{ .root_source_file = b.path(PATH ++ "Binding/root.zig") });
        const commonMod = b.addModule("Common", .{ .root_source_file = b.path(PATH ++ "Common/root.zig") });
        const deviceMod = b.addModule("Device", .{ .root_source_file = b.path(PATH ++ "Device/root.zig") });
        const transportMod = b.addModule("Transport", .{ .root_source_file = b.path(PATH ++ "Transport/root.zig") });

        bindingMod.addImport("Common", commonMod);

        deviceMod.addImport("Common", commonMod);

        transportMod.addImport("Binding", bindingMod);
        transportMod.addImport("Common", commonMod);

        return .{
            .binding = bindingMod,
            .common = commonMod,
            .device = deviceMod,
            .transport = transportMod,
        };
    }
};

pub fn configure(
    option: OptionData, 
    target: Build.ResolvedTarget,
    b:      *Build
) *Step.Compile
{
    const result = b.addLibrary(.{
        .name = "janus",
        .linkage = option.linkmode,
        .root_module = createMod(
            PATH,
            option, 
            target, 
            true, 
            b
        )
    }); 
    configMod(result, option);

    return result;
}