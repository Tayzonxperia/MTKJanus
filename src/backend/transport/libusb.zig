// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const root = @This();
const std = @import("std");

const mem = std.mem;
const Allocator = mem.Allocator;

const binding = @cImport(@cInclude("libusb-1.0/libusb.h"));
const usb_device_handle = binding.libusb_device_handle;
const usb_context = binding.libusb_context;
const usb_close = binding.libusb_close;
const usb_exit = binding.libusb_exit;
const usb_init = binding.libusb_init;
const usb_init_context = binding.libusb_init_context;
const usb_open_device_with_vid_pid = binding.libusb_open_device_with_vid_pid;


pub fn init() !*usb_context
{
    var ctx: *usb_context = null;
    
    const ret = usb_init(&ctx);
    if (ret == 0) { return error.InitFailed; }

    return ctx;
}

pub fn open(ctx: *usb_context, vid: u16, pid: u16) !*usb_device_handle
{
    const handle = usb_open_device_with_vid_pid(ctx, vid, pid);
    if (handle == null) { return error.DeviceNotFound; }

    return handle;
}

pub fn close(handle: *usb_device_handle) void
{ usb_close(handle); }

pub fn deinit(ctx: *usb_context) void
{ usb_exit(ctx); }