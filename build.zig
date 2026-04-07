// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const builtin = std.builtin;
const Target = std.Target;

const Build = std.Build;
const Step = Build.Step;

// No build system to modulize this so we import manually
const builder = @import("build/root.zig");
const common = builder.common;
const backend = builder.backend;
const frontend = builder.frontend;
const debugger = builder.debugger;



pub fn build(b: *Build) void 
{
    const optionData = common.OptionData.init(b);
    const option = common.OptionData.obtain(b);
    optionData.set(option);

    const targetData = common.TargetData.init(optionData);
    const target = targetData.resolve(b);
    
    const lib_dir = "Target/lib";
    const exe_dir = "Target/bin";

    b.lib_dir = lib_dir;
    b.exe_dir = exe_dir;

    const program = optionData.programkind orelse .backend;
    switch (program) {
        .backend => {
            const lib_modules = backend.Modules.init(b);

            const lib = backend.configure(optionData, target, b);
            
            lib.root_module.addImport("Binding", lib_modules.binding);
            lib.root_module.addImport("Common", lib_modules.common);
            lib.root_module.addImport("Device", lib_modules.device);
            lib.root_module.addImport("Transport", lib_modules.transport);

            b.addSearchPrefix("/usr");
            lib.root_module.addSystemIncludePath(b.path("libusb-1.0"));
            lib.root_module.linkSystemLibrary("usb-1.0", .{}); 
            
            lib.root_module.addRPath(b.path(lib_dir));
            
            b.installArtifact(lib);
        },
        .frontend => {
            const lib_modules = backend.Modules.init(b);
            const exe_modules = frontend.Modules.init(b);
            
            const lib = backend.configure(optionData, target, b);
            const exe = frontend.configure(optionData, target, b);

            lib.root_module.addImport("Binding", lib_modules.binding);
            lib.root_module.addImport("Common", lib_modules.common);
            lib.root_module.addImport("Device", lib_modules.device);
            lib.root_module.addImport("Transport", lib_modules.transport);

            _ = exe_modules;

            exe.root_module.linkLibrary(lib);

            lib.root_module.addRPath(b.path(lib_dir));
            exe.root_module.addRPath(b.path(lib_dir));

            b.installArtifact(lib);
            b.installArtifact(exe);
        },
        .debugger => {
            const lib_modules = backend.Modules.init(b);
            const exe_modules = debugger.Modules.init(b);
            
            const lib = backend.configure(optionData, target, b);
            const exe = debugger.configure(optionData, target, b);

            lib.root_module.addImport("Binding", lib_modules.binding);
            lib.root_module.addImport("Common", lib_modules.common);
            lib.root_module.addImport("Device", lib_modules.device);
            lib.root_module.addImport("Transport", lib_modules.transport);

            _ = exe_modules;

            lib.root_module.addRPath(b.path(lib_dir));
            exe.root_module.addRPath(b.path(lib_dir));

            b.installArtifact(lib);
            b.installArtifact(exe);
        }
    }   
}