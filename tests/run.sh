#!/bin/sh
# SPDX-License-Identifier: MIT
# Validate configuration and the staged installation without hardware access.
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
make -s -C "$here" install DESTDIR="$stage"
nm=$stage/usr/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf
passed=0
check() { "$@"; passed=$((passed + 1)); }
check grep -qx 'match-device=driver:mt7932-fullmac' "$nm"
check grep -qx 'wifi.scan-rand-mac-address=no' "$nm"
check grep -qx 'wifi.cloned-mac-address=permanent' "$nm"
check cmp "$here/network/networkmanager.conf" "$nm"
quirks=$stage/usr/share/libinput/60-aurora-neo-j700.quirks
check grep -qx 'MatchDeviceTree=\*j700\*' "$quirks"
check grep -qx 'AttrPalmSizeThreshold=0' "$quirks"
check cmp "$here/libinput/j700-trackpad.quirks" "$quirks"
if command -v libinput >/dev/null 2>&1; then
	check libinput quirks validate --data-dir "$stage/usr/share/libinput"
fi
[ "$(find "$stage" -type f | wc -l | tr -d ' ')" = 2 ]
passed=$((passed + 1))
echo "passed $passed checks"
