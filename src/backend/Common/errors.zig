// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2025-2026 Taylor (Wakana Kisarazu)



pub const Binding = struct 
{
    pub const libusb = error {
        IoError,
        InvalidParam,
        AccessError,
        NoDevice,
        NotFound,
        Busy,
        Timeout,
        Overflow,
        Pipe,
        Interrupted,
        NoMem,
        NotSupported,
        Other,
    };

    /// Assume success if not speced -> ((TODO: Document all this))
    pub fn libusbCode(err: libusb) i8 {
        return switch (err) {
            .IoError        => -1,
            .InvalidParam   => -2,
            .AccessError    => -3,
            .NoDevice       => -4,
            .NotFound       => -5,
            .Busy           => -6,
            .Timeout        => -7,
            .Overflow       => -8,
            .Pipe           => -9,
            .Interrupted    => -10,
            .NoMem          => -11,
            .NotSupported   => -12,
            .Other          => -99,
            _               => 0,
        };
    }
};

pub const Device = struct 
{
    pub const Chip = error {
        InvalidLookup
    };

    pub const Flash = error {
        ResponseTooLong,
        ResponseTooShort,
        BadRpmbRegion,
    };

    pub const Gpt = error {
        // STUB
    };
};

pub const Transport = struct 
{
    // STUB
};