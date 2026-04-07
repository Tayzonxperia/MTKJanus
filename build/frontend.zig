// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");

const Build = std.Build;
const Step = Build.Step;

const common = @import("common.zig");
const OptionData = common.OptionData;
const createMod = common.createMod;
const configMod = common.configMod;



pub const PATH: []const u8     = "src/frontend/";

pub const Modules = struct 
{

    pub fn init(b: *Build) @This() {
        _ = b;
        return .{
        };
    }
};

pub fn configure(
    option: OptionData, 
    target: Build.ResolvedTarget,
    b: *Build
) *Step.Compile
{
    const result = b.addExecutable(.{
        .name = "janus-cli",
        .linkage = option.linkmode,
        .root_module = createMod(
            PATH,
            option, 
            target, 
            null, 
            b
        )
    }); 
    configMod(result, option);

    return result;
}