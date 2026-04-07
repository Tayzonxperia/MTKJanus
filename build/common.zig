// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const std = @import("std");
const builtin = std.builtin;
const Target = std.Target;

const Build = std.Build;
const Step = Build.Step;

const startsWith = std.mem.startsWith;



pub const ProgramKind = enum
{
    backend,
    frontend,
    debugger,
};

pub const OptionData = struct 
{
    optimizemode:       builtin.OptimizeMode,
    linkmode:           builtin.LinkMode,
    code_model:         builtin.CodeModel,
    arch:               Target.Cpu.Arch,
    tag:                Target.Os.Tag,
    abi:                Target.Abi,
    programkind:        ?ProgramKind,
    verbose_compile:    bool,
    use_libc:           bool,
    use_libcpp:         bool,
    use_rt:             bool,
    provide_libusb:     bool,
    force_llvm:         bool,
    support_valgrind:   bool,

    pub fn init(b: *Build) @This() {
        return .{
            .optimizemode = b.option(
                builtin.OptimizeMode,
                "optimize_mode",
                "Optimization mode"
            ) orelse .Debug,

            .linkmode = b.option(
                builtin.LinkMode,
                "link_mode",
                "Linking mode",
            ) orelse .dynamic,

            .code_model = b.option(
                builtin.CodeModel,
                "code_model",
                "Code model [Experimental]",
            ) orelse .default,

            .arch = b.option(
                Target.Cpu.Arch,
                "arch",
                "CPU architecture",
            ) orelse .x86_64,

            .tag = b.option(
                Target.Os.Tag,
                "tag",
                "OS tag"
            ) orelse .linux,

            .abi = b.option(
                Target.Abi,
                "abi",
                "Program ABI",
            ) orelse .gnu,

            .programkind = b.option(
                ProgramKind,
                "program_kind",
                "Program to compile",
            ), 

            .verbose_compile = b.option(
                bool,
                "verbose_compile",
                "Toggle verbose logs [Experimental, Debug]?",
            ) orelse false,

            .use_libc = b.option(
                bool,
                "use_libc",
                "Utilise libc?",
            ) orelse true,

            .use_libcpp = b.option(
                bool,
                "use_libcpp",
                "Utilise libcpp? [Experimental]",
            ) orelse false,
            
            .use_rt = b.option(
                bool,
                "use_rt",
                "Utilise compiler_rt and ubsan_rt? [Experimental, Debug]",
            ) orelse false,

            .provide_libusb = b.option(
                bool,
                "provide_libusb",
                "Compile libusb instead of using system libusb?",
            ) orelse false,

            .force_llvm = b.option(
                bool,
                "force_llvm",
                "Force compilation with LLVM/LLD?"
            ) orelse false,

            .support_valgrind = b.option(
                bool,
                "support_valgrind",
                "Add support for valgrind memory debugger? [Debug]"
            ) orelse false,
        };
    }

    pub fn obtain(b: *Build) *Step.Options 
    { return b.addOptions(); }

    pub fn set(self: @This(), option: *Step.Options) void {
        option.addOption(builtin.OptimizeMode, "optimizemode", self.optimizemode);
        option.addOption(builtin.LinkMode, "linkmode", self.linkmode);
        option.addOption(Target.Cpu.Arch, "arch", self.arch);
        option.addOption(Target.Os.Tag, "tag", self.tag);
        option.addOption(Target.Abi, "abi", self.abi);
        option.addOption(?ProgramKind, "programkind", self.programkind);
        option.addOption(bool, "verbose_compile", self.verbose_compile);
        option.addOption(bool, "use_libc", self.use_libc);
        option.addOption(bool, "use_libcpp", self.use_libcpp);
        option.addOption(bool, "use_rt", self.use_rt);
        option.addOption(bool, "provide_libusb", self.provide_libusb);
        option.addOption(bool, "force_llvm", self.force_llvm);
        option.addOption(bool, "support_valgrind", self.support_valgrind);
    }
};

pub const TargetData = struct 
{
    arch:   Target.Cpu.Arch,
    tag:    Target.Os.Tag,
    abi:    Target.Abi,
    ofmt:   Target.ObjectFormat,

    pub fn init(options: OptionData) @This() {
        return .{
            .arch = options.arch,
            .tag = options.tag,
            .abi = options.abi,
            .ofmt = Target.ObjectFormat.default(
                options.tag,
                options.arch,
            )
        };
    }

    pub fn resolve(self: @This(), b: *Build) Build.ResolvedTarget {
        return b.resolveTargetQuery(.{
            .cpu_arch = self.arch,
            .os_tag = self.tag,
            .abi = self.abi,
            .ofmt = self.ofmt,
        });
    }

    pub fn isLinux(self: @This()) bool 
    { return (self.tag == .linux and (self.abi.isGnu() or self.abi.isMusl())); }

    pub fn isBsd(self: @This()) bool
    { return (self.tag.isBSD() and (self.abi.isGnu() or self.abi.isMusl())); }

    pub fn isWindows(self: @This()) bool
    { return (self.tag == .windows and self.abi == .msvc); }
};

pub fn createMod(
    comptime path: []const u8,
    option: OptionData,
    target: Build.ResolvedTarget,
    pic: ?bool,
    b: *Build,
) *Build.Module 
{
    return b.createModule(.{
        .root_source_file = b.path(path ++ "entry.zig"),
        .optimize = option.optimizemode,
        .target = target,
        .code_model = option.code_model,
        .pic = pic,
        .link_libc = option.use_libc,
        .link_libcpp = option.use_libcpp,
    });
}

pub fn configMod(
    result: *Step.Compile,
    option: OptionData
) void 
{   
    if (option.optimizemode != .Debug) {
        result.link_data_sections = true;
        result.link_function_sections = true;
        result.link_gc_sections = true;
        result.root_module.strip = true;
        result.bundle_compiler_rt = option.use_rt;
        result.bundle_ubsan_rt = option.use_rt;
        result.compress_debug_sections = .zstd;
        result.lto = switch (option.optimizemode) {
            // No `.Debug => .none` needed as
            // it already gets branched out 
            .ReleaseSafe    => .thin,
            else            => .full,
        };
    } else {
        result.root_module.error_tracing = true;
        result.compress_debug_sections = .none;
    }

    if (option.verbose_compile) {
        result.verbose_cc = true;
        result.verbose_link = true;
    }

    if (option.force_llvm) {
        result.use_llvm = true;
        result.use_lld = true;
    }

    if (option.support_valgrind) 
    { result.root_module.valgrind = true; }   
}