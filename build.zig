// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const builtin = std.builtin;
const Build = std.Build;
const Target = std.Target;



const BACKEND_PATH = "src/backend/";
const FRONTEND_PATH = "src/frontend/";
const DEBUGGER_PATH = "src/debugger/";

/// A struct representing the build options
const OptionData = struct 
{   
    optimize:   builtin.OptimizeMode,
    arch:       Target.Cpu.Arch,
    os_tag:     Target.Os.Tag,
    abi:        Target.Abi,

    fn init(b: *Build) @This() {
        return .{
            .optimize = b.option(
                builtin.OptimizeMode,
                "optimize",
                "Optimization mode",
            ) orelse .Debug,

            .arch = b.option(
                Target.Cpu.Arch,
                "arch",
                "CPU architecture",
            ) orelse .x86_64,

            .os_tag = b.option(
                Target.Os.Tag,
                "ostag",
                "OS tag",
            ) orelse .linux,

            .abi = b.option(
                Target.Abi,
                "abi",
                "ABI",
            ) orelse .gnu
        };   
    }
};

pub fn build(b: *Build) void
{   
    // ── Options and targets ─────────────────────────────────────────

    const optionData = OptionData.init(b);
    const optionRef = b.addOptions();

    optionRef.addOption(builtin.OptimizeMode, "buildOptimizeMode", optionData.optimize);
    optionRef.addOption(Target.Cpu.Arch, "buildCpuArch", optionData.arch);
    optionRef.addOption(Target.Os.Tag, "buildOsTag", optionData.os_tag);
    optionRef.addOption(Target.Abi, "buildAbi", optionData.abi);

    const target = b.resolveTargetQuery(.{
        .cpu_arch = optionData.arch,
        .os_tag = optionData.os_tag,
        .abi = optionData.abi,
        .ofmt = .default(optionData.os_tag, optionData.arch)
    });


    // ── Dependencies and modules ─────────────────────────────────────────

    const usb_dep = b.dependency("libusb", .{});
    const usb_lib = usb_dep.artifact("usb");

    const transport = b.addModule("transport", .{ .root_source_file = b.path(BACKEND_PATH ++ "transport/root.zig") } );
    const device = b.addModule("device", .{ .root_source_file = b.path(BACKEND_PATH ++ "device/root.zig") } );

    //const FrontendModules = struct {

    //};

    //const DebuggerModules = struct {

    //};

    // ── MTKJanus backend ─────────────────────────────────────────

    const backend = b.addLibrary(.{
        .name = "janus",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/backend/entry.zig"),
            .optimize = optionData.optimize,
            .target = target,
            .link_libc = true,
        })
    });
    backend.root_module.addImport("transport", transport);
    backend.root_module.addImport("device", device);


    // ── MTKJanus frontend ─────────────────────────────────────────

    const frontend = b.addExecutable(.{
        .name = "janus-cli",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/frontend/entry.zig"),
            .optimize = optionData.optimize,
            .target = target,
            .link_libc = true,
        })
    });
    frontend.root_module.addImport("device", device);

    // ── MTKJanus debugger ─────────────────────────────────────────

    const debugger = b.addExecutable(.{
        .name = "janus-dbg",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/debugger/entry.zig"),
            .optimize = optionData.optimize,
            .target = target,
            .link_libc = true,
        })
    });


    // ── Finalization ─────────────────────────────────────────

    backend.root_module.linkLibrary(usb_lib);
    frontend.root_module.linkLibrary(backend);
    debugger.root_module.linkLibrary(backend);

    const usb_lib_install = b.addInstallArtifact(usb_lib, .{});
    const backend_install = b.addInstallArtifact(backend, .{});
    backend.step.dependOn(&usb_lib_install.step);
    frontend.step.dependOn(&backend_install.step);
    debugger.step.dependOn(&backend_install.step);
    const frontend_install = b.addInstallArtifact(frontend, .{});
    const debugger_install = b.addInstallArtifact(debugger, .{});
    b.default_step.dependOn(&frontend_install.step);
    b.default_step.dependOn(&debugger_install.step);
}