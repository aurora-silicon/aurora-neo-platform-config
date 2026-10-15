#!/bin/bash
# SPDX-License-Identifier: MIT
# MacBook Neo (J700): put the Apple display driver in the initramfs and load it
# before udev coldplug reaches it, so a USB-C external display shows the boot
# console and the disk passphrase prompt with the lid closed.

check() {
    return 0
}

depends() {
    return 0
}

installkernel() {
    # appledrm drives both displays and provides the Type-C display route the
    # sn201202x port waits for. Include it in host-only images too. A kernel
    # without it still gets an initramfs.
    hostonly='' instmods appledrm || :
}

install() {
    inst_multiple bash grep modprobe
    inst_script "$moddir/aurora-neo-display-early.sh" /usr/libexec/aurora-neo-display-early
    if dracut_module_included "systemd"; then
        inst_simple "$moddir/aurora-neo-display-early.service" \
            "$systemdsystemunitdir/aurora-neo-display-early.service"
        $SYSTEMCTL -q --root "$initdir" add-wants sysinit.target \
            aurora-neo-display-early.service
    else
        inst_hook cmdline 90 "$moddir/aurora-neo-display-early.sh"
    fi
}
