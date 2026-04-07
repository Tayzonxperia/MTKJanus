// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)
const root = @This();
const std = @import("std");

const Common = @import("Common");
const errors = Common.errors.Binding;

/// MTKJanus C import for libusb
const binder = @cImport(@cInclude("libusb-1.0/libusb.h"));



// ────────────────────────────────────────
// May as well just fucking bind all of 
// libusb because `binder.libusb_func` is
// downright painful to look at...
//
// I don't do these comments often but
// i think i need to document this spam
//
// This took me 2 hours holy...
// ────────────────────────────────────────

const usb_alloc_streams = binder.libusb_alloc_streams;
const usb_alloc_transfer = binder.libusb_alloc_transfer;
const usb_attach_kernel_driver = binder.libusb_attach_kernel_driver;

const usb_bulk_transfer = binder.libusb_bulk_transfer;
const usb_bos_descriptor = binder.libusb_bos_descriptor;
const usb_bos_capability_descriptor = binder.libusb_bos_dev_capability_descriptor;
const usb_bos_type = binder.libusb_bos_type;

const usb_cancel_transfer = binder.libusb_cancel_transfer;
const usb_claim_interface = binder.libusb_claim_interface;
const usb_clear_halt = binder.libusb_clear_halt;
const usb_close = binder.libusb_close;
const usb_control_transfer = binder.libusb_control_transfer;
const usb_control_transfer_get_data = binder.libusb_control_transfer_get_data;
const usb_control_transfer_get_setup = binder.libusb_control_transfer_get_setup;
const usb_cpu_to_le16 = binder.libusb_cpu_to_le16;
const usb_capability = binder.libusb_capability;
const usb_class_code = binder.libusb_class_code;
const usb_config_descriptor = binder.libusb_config_descriptor;
const usb_container_id_descriptor = binder.libusb_container_id_descriptor;
const usb_context = binder.libusb_context;
const usb_control_setup = binder.libusb_control_setup;

const usb_detach_kernel_driver = binder.libusb_detach_kernel_driver;
const usb_dev_mem_alloc = binder.libusb_dev_mem_alloc;
const usb_dev_mem_free = binder.libusb_dev_mem_free;
const usb_descriptor_type = binder.libusb_descriptor_type;
const usb_device = binder.libusb_device;
const usb_device_descriptor = binder.libusb_device_descriptor;
const usb_device_handle = binder.libusb_device_handle;

const usb_error_name = binder.libusb_error_name;
const usb_event_handler_active = binder.libusb_event_handler_active;
const usb_event_handling_ok = binder.libusb_event_handling_ok;
const usb_exit = binder.libusb_exit;
const usb_endpoint_descriptor = binder.libusb_endpoint_descriptor;
const usb_endpoint_direction = binder.libusb_endpoint_direction;
const usb_endpoint_transfer_type = binder.libusb_endpoint_transfer_type;
const usb_error = binder.libusb_error;

const usb_fill_bulk_stream_transfer = binder.libusb_fill_bulk_stream_transfer;
const usb_fill_bulk_transfer = binder.libusb_fill_bulk_transfer;
const usb_fill_control_setup = binder.libusb_fill_control_setup;
const usb_fill_control_transfer = binder.libusb_fill_control_transfer;
const usb_fill_interrupt_transfer = binder.libusb_fill_interrupt_transfer;
const usb_fill_iso_transfer = binder.libusb_fill_iso_transfer;
const usb_free_bos_descriptor = binder.libusb_free_bos_descriptor;
const usb_free_config_descriptor = binder.libusb_free_config_descriptor;
const usb_free_container_id_descriptor = binder.libusb_free_container_id_descriptor;
const usb_free_device_list = binder.libusb_free_device_list;
const usb_free_interface_association_descriptors = binder.libusb_free_interface_association_descriptors;
const usb_free_platform_descriptor = binder.libusb_free_platform_descriptor;
const usb_free_pollfds = binder.libusb_free_pollfds;
const usb_free_ss_endpoint_companion_descriptor = binder.libusb_free_ss_endpoint_companion_descriptor;
const usb_free_ss_usb_device_capability_descriptor = binder.libusb_free_ss_usb_device_capability_descriptor;
const usb_free_ssplus_usb_device_capability_descriptor = binder.libusb_free_ssplus_usb_device_capability_descriptor;
const usb_free_streams = binder.libusb_free_streams;
const usb_free_streams_transfer = binder.libusb_free_transfer;
const usb_free_usb_2_0_extension_descriptor = binder.libusb_free_usb_2_0_extension_descriptor;

const usb_get_active_config_descriptor = binder.libusb_get_active_config_descriptor;
const usb_get_active_interface_association_descriptors = binder.libusb_get_active_interface_association_descriptors;
const usb_get_bos_descriptor = binder.libusb_get_bos_descriptor;
const usb_get_bus_number = binder.libusb_get_bus_number;
const usb_get_config_descriptor = binder.libusb_get_config_descriptor;
const usb_get_config_descriptor_by_value = binder.libusb_get_config_descriptor_by_value;
const usb_get_configuration = binder.libusb_get_configuration;
const usb_get_container_id_descriptor = binder.libusb_get_container_id_descriptor;
const usb_get_descriptor = binder.libusb_get_descriptor;
const usb_get_device = binder.libusb_get_device;
const usb_get_device_address = binder.libusb_get_device_address;
const usb_get_device_descriptor = binder.libusb_get_device_descriptor;
const usb_get_device_list = binder.libusb_get_device_list;
const usb_get_device_speed = binder.libusb_get_device_speed;
const usb_get_interface_association_descriptors = binder.libusb_get_interface_association_descriptors;
const usb_get_iso_packet_buffer = binder.libusb_get_iso_packet_buffer;
const usb_get_iso_packet_buffer_simple = binder.libusb_get_iso_packet_buffer_simple;
const usb_get_max_alt_packet_size = binder.libusb_get_max_alt_packet_size;
const usb_get_max_iso_packet_size = binder.libusb_get_max_iso_packet_size;
const usb_get_max_packet_size = binder.libusb_get_max_packet_size;
const usb_get_next_timeout = binder.libusb_get_next_timeout;
const usb_get_parent = binder.libusb_get_parent;
const usb_get_platform_descriptor = binder.libusb_get_platform_descriptor;
const usb_get_pollfds = binder.libusb_get_pollfds;
const usb_get_port_number = binder.libusb_get_port_number;
const usb_get_port_numbers= binder.libusb_get_port_numbers;
const usb_get_port_path= binder.libusb_get_port_path;
const usb_get_ss_endpoint_companion_descriptor = binder.libusb_get_ss_endpoint_companion_descriptor;
const usb_get_ss_usb_device_capability_descriptor = binder.libusb_get_ss_usb_device_capability_descriptor;
const usb_get_ssplus_usb_device_capability_descriptor = binder.libusb_get_ssplus_usb_device_capability_descriptor;
const usb_get_string_descriptor = binder.libusb_get_string_descriptor;
const usb_get_string_descriptor_ascii = binder.libusb_get_string_descriptor_ascii;
const usb_get_usb_2_0_extension_descriptor = binder.libusb_get_usb_2_0_extension_descriptor;
const usb_get_version = binder.libusb_get_version;

const usb_handle_events = binder.libusb_handle_events;
const usb_handle_events_completed = binder.libusb_handle_events_completed;
const usb_handle_events_locked = binder.libusb_handle_events_locked;
const usb_handle_events_timeout = binder.libusb_handle_events_timeout;
const usb_handle_events_timeout_completed = binder.libusb_handle_events_timeout_completed;
const usb_has_capability = binder.libusb_has_capability;
const usb_hotplug_deregister_callback = binder.libusb_hotplug_deregister_callback;
const usb_hotplug_get_user_data = binder.libusb_hotplug_get_user_data;
const usb_hotplug_register_callback = binder.libusb_hotplug_register_callback;
const usb_hotplug_callback_fn = binder.libusb_hotplug_callback_fn;
const usb_hotplug_callback_handle = binder.libusb_hotplug_callback_handle;
const usb_hotplug_callback_event = binder.libusb_hotplug_event;
const usb_hotplug_callback_flag = binder.libusb_hotplug_flag;

const usb_init = binder.libusb_init;
const usb_init_context = binder.libusb_init_context;
const usb_interrupt_event_handler = binder.libusb_interrupt_event_handler;
const usb_interrupt_transfer = binder.libusb_interrupt_transfer;
const usb_init_option = binder.libusb_init_option;
const usb_interface = binder.libusb_interface;
const usb_interface_association_descriptor = binder.libusb_interface_association_descriptor;
const usb_interface_association_descriptor_array = binder.libusb_interface_association_descriptor_array;
const usb_interface_descriptor = binder.libusb_interface_descriptor;
const usb_iso_packet_descriptor = binder.libusb_iso_packet_descriptor;
const usb_iso_sync_type = binder.libusb_iso_sync_type;
const usb_iso_usage_type = binder.libusb_iso_usage_type;

const usb_kernel_driver_active = binder.libusb_kernel_driver_active;

const usb_le16_to_cpu = binder.libusb_le16_to_cpu;
const usb_lock_event_waiters = binder.libusb_lock_event_waiters;
const usb_lock_events = binder.libusb_lock_events;
const usb_log_cb = binder.libusb_log_cb;
const usb_log_cb_mode = binder.libusb_log_cb_mode;
const usb_log_level = binder.libusb_log_level;

const usb_open = binder.libusb_open;
const usb_open_device_with_vid_pid = binder.libusb_open_device_with_vid_pid;
const usb_option = binder.libusb_option;

const usb_pollfds_handle_timeouts = binder.libusb_pollfds_handle_timeouts;
const usb_platform_descriptor = binder.libusb_platform_descriptor;
const usb_pollfd = binder.libusb_pollfd;
const usb_pollfd_added_cd = binder.libusb_pollfd_added_cb;
const usb_pollfd_removed_cd = binder.libusb_pollfd_removed_cb;

const usb_ref_device = binder.libusb_ref_device;
const usb_release_interface = binder.libusb_release_interface;
const usb_reset_device = binder.libusb_reset_device;
const usb_request_recipient = binder.libusb_request_recipient;
const usb_request_type = binder.libusb_request_type;

const usb_set_auto_detach_kernel_driver = binder.libusb_set_auto_detach_kernel_driver;
const usb_set_configuration = binder.libusb_set_configuration;
const usb_set_debug = binder.libusb_set_debug;
const usb_set_interface_alt_setting = binder.libusb_set_interface_alt_setting;
const usb_set_iso_packet_lengths = binder.libusb_set_iso_packet_lengths;
const usb_set_log_cb = binder.libusb_set_log_cb;
const usb_set_option = binder.libusb_set_option;
const usb_set_pollfd_notifiers = binder.libusb_set_pollfd_notifiers;
const usb_setlocale = binder.libusb_setlocale;
const usb_strerror = binder.libusb_strerror;
const usb_submit_transfer = binder.libusb_submit_transfer;
const usb_speed = binder.libusb_speed;
const usb_ss_endpoint_companion_descriptor = binder.libusb_ss_endpoint_companion_descriptor;
const usb_ss_usb_device_capability_attributes = binder.libusb_ss_usb_device_capability_attributes;
const usb_ss_usb_device_capability_descriptor = binder.libusb_ss_usb_device_capability_descriptor;
const usb_ssplus_sublink_attribute = binder.libusb_ssplus_sublink_attribute;
const usb_ssplus_usb_device_capability_descriptor = binder.libusb_ssplus_usb_device_capability_descriptor;
const usb_standard_request = binder.libusb_standard_request;
const usb_superspeedplus_sublink_attribute_exponent = binder.libusb_superspeedplus_sublink_attribute_exponent;
const usb_superspeedplus_sublink_attribute_link_protocol = binder.libusb_superspeedplus_sublink_attribute_link_protocol;
const usb_superspeedplus_sublink_attribute_sublink_direction = binder.libusb_superspeedplus_sublink_attribute_sublink_direction;
const usb_superspeedplus_sublink_attribute_sublink_type = binder.libusb_superspeedplus_sublink_attribute_sublink_type;
const usb_supported_speed = binder.libusb_supported_speed;

const usb_transfer_get_stream_id = binder.libusb_transfer_get_stream_id;
const usb_transfer_set_stream_id = binder.libusb_transfer_set_stream_id;
const usb_try_lock_events = binder.libusb_try_lock_events;
const usb_transfer = binder.libusb_transfer;
const usb_transfer_cb_fn = binder.libusb_transfer_cb_fn;
const usb_transfer_flags = binder.libusb_transfer_flags;
const usb_transfer_status = binder.libusb_transfer_status;
const usb_transfer_type = binder.libusb_transfer_type;

const usb_unlock_event_waiter = binder.libusb_unlock_event_waiters;
const usb_unlock_events = binder.libusb_unlock_events;
const usb_unref_device = binder.libusb_unref_device;
const usb_usb_2_0_extension_attributes = binder.libusb_usb_2_0_extension_attributes;
const usb_usb_usb_2_0_extension_descriptor = binder.libusb_usb_2_0_extension_descriptor;

const usb_version = binder.libusb_version;

const usb_wait_for_event = binder.libusb_wait_for_event;
const usb_wrap_sys_device = binder.libusb_wrap_sys_device;

// Why is it a unknown type? will this fix it... hope so ffs
const usb_API_VERSION: u32 = @as(binder.LIBUSB_API_VERSION, u32);

pub fn init() errors.libusb![*c]?*usb_context
{
    const ctx: [*c]?*usb_context = undefined;

    const result = usb_init_context(ctx, null, 0);
    if (result != 0) { return errors.libusb.NotSupported; }

    return ctx;
}

pub fn deinit(ctx: [*c]?*usb_context) void
{ usb_exit(ctx); }

pub fn openDevice(dev: ?*usb_device, dev_handle: [*c]?*usb_device_handle) errors.libusb![*c]?*usb_device_handle
{
    const result = usb_open(dev, dev_handle);
    if (result != 0) { return errors.libusb.NotFound; }

    return result;
}

pub fn openDeviceWithVidPid(ctx: ?*usb_context, vid: u16, pid: u16) errors.libusb![*c]?*usb_device_handle
{
    const result = usb_open_device_with_vid_pid(ctx, vid, pid);
    if (result == null) { return errors.libusb.NotFound; }

    return result;
}

pub fn closeDevice(dev_handle: ?*usb_device_handle) void
{ usb_close(dev_handle); }