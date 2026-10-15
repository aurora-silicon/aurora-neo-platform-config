#!/bin/bash
# SPDX-License-Identifier: MIT
# Load the Apple display driver on the MacBook Neo before udev coldplug reaches
# it. The USB-C external display (DCPEXT) needs appledrm twice over: it drives
# the display, and it provides the Type-C display route that the sn201202x port
# waits for before it sets the DisplayPort mux.
#
# Other machines are left to udev. A failed load never blocks the boot: udev
# loads the same module again when it reaches the device.
compatible=${AURORA_DT_COMPATIBLE:-/sys/firmware/devicetree/base/compatible}
modprobe_command=${AURORA_MODPROBE:-modprobe}

if grep -aq 'apple,j700' "$compatible" 2>/dev/null; then
    "$modprobe_command" -q appledrm ||
        echo 'Aurora: early appledrm load failed; udev will load it' >&2
fi
:
