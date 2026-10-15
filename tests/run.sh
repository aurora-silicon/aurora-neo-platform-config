#!/bin/sh
# SPDX-License-Identifier: MIT
# Validate configuration and the staged installation without hardware access.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
make -s -C "$here" install DESTDIR="$stage"
nm=$stage/usr/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf
mod=$stage/usr/lib/dracut/modules.d/90aurora-neo-display
conf=$stage/usr/lib/dracut/dracut.conf.d/50-aurora-neo-display.conf
passed=0
check() { "$@"; passed=$((passed + 1)); }
check grep -qx 'match-device=driver:mt7932-fullmac' "$nm"
check grep -qx 'wifi.scan-rand-mac-address=no' "$nm"
check grep -qx 'wifi.cloned-mac-address=permanent' "$nm"
check cmp "$here/network/networkmanager.conf" "$nm"
[ "$(find "$stage" -type f | wc -l | tr -d ' ')" = 5 ]
passed=$((passed + 1))

# dracut: the module is enabled, and its files are where module-setup.sh looks.
check grep -qx 'add_dracutmodules+=" aurora-neo-display "' "$conf"
check test -x "$mod/module-setup.sh"
check test -x "$mod/aurora-neo-display-early.sh"
check grep -qx 'ExecStart=/usr/libexec/aurora-neo-display-early' "$mod/aurora-neo-display-early.service"
check grep -qx 'DefaultDependencies=no' "$mod/aurora-neo-display-early.service"
check bash -n "$mod/module-setup.sh"
check bash -n "$mod/aurora-neo-display-early.sh"

# The early loader: modprobe appledrm on a J700 only, and never fail the unit.
fix=$stage/fixture
mkdir -p "$fix"
cat >"$fix/modprobe" <<'MP'
#!/bin/sh
echo "$*" >>"$MODPROBE_LOG"
exit "${MODPROBE_STATUS:-0}"
MP
chmod +x "$fix/modprobe"
early() {
    : >"$fix/log"
    AURORA_DT_COMPATIBLE=$fix/compatible AURORA_MODPROBE=$fix/modprobe \
        MODPROBE_LOG=$fix/log MODPROBE_STATUS=${1:-0} \
        bash "$mod/aurora-neo-display-early.sh" 2>"$fix/err"
}
printf 'apple,j700\000apple,t8140\000apple,arm-platform\000' >"$fix/compatible"
check early
check grep -qx -- '-q appledrm' "$fix/log"
check early 1
check grep -q 'udev will load it' "$fix/err"
printf 'apple,j413\000apple,t8112\000apple,arm-platform\000' >"$fix/compatible"
check early
check test ! -s "$fix/log"
rm -f "$fix/compatible"
check early
check test ! -s "$fix/log"

# module-setup.sh under stub dracut helpers: appledrm via instmods with
# host-only off, and the unit wanted by sysinit.target.
calls=$fix/calls
: >"$calls"
bash -c '
    set -eu
    moddir=$1 initdir=$2 calls=$3
    systemdsystemunitdir=/usr/lib/systemd/system
    SYSTEMCTL="rec systemctl" hostonly=yes
    rec() { echo "$*" >>"$calls"; }
    instmods() { echo "instmods hostonly=[$hostonly] $*" >>"$calls"; }
    inst_multiple() { rec inst_multiple "$@"; }
    inst_script() { rec inst_script "$@"; }
    inst_simple() { rec inst_simple "$@"; }
    inst_hook() { rec inst_hook "$@"; }
    dracut_module_included() { [ "$1" = systemd ]; }
    . "$moddir/module-setup.sh"
    check
    installkernel
    install
    [ "$hostonly" = yes ]
' setup "$mod" "$fix/initrd" "$calls"
passed=$((passed + 1))
check grep -qx 'instmods hostonly=\[\] appledrm' "$calls"
check grep -qx "inst_script $mod/aurora-neo-display-early.sh /usr/libexec/aurora-neo-display-early" "$calls"
check grep -qx "inst_simple $mod/aurora-neo-display-early.service /usr/lib/systemd/system/aurora-neo-display-early.service" "$calls"
check grep -qx "systemctl -q --root $fix/initrd add-wants sysinit.target aurora-neo-display-early.service" "$calls"
check grep -q '^inst_multiple .*modprobe' "$calls"
echo "passed $passed checks"
