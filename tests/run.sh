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
[ "$(find "$stage" -type f | wc -l | tr -d ' ')" = 2 ]
passed=$((passed + 1))

rule=$stage/usr/lib/udev/rules.d/80-aurora-neo-charge-limit.rules
check cmp "$here/udev/80-aurora-neo-charge-limit.rules" "$rule"
# Run the exact PROGRAM command against NUL-delimited public DT fixtures.
printf 'apple,j700\000apple,t8140\000' > "$stage/j700"
printf 'apple,j313\000apple,t8103\000' > "$stage/other"
printf 'apple,j700-extra\000' > "$stage/prefix"
check grep -z -x -q apple,j700 "$stage/j700"
if grep -z -x -q apple,j700 "$stage/other"; then exit 1; fi
passed=$((passed + 1))
if grep -z -x -q apple,j700 "$stage/prefix"; then exit 1; fi
passed=$((passed + 1))
if grep -z -x -q apple,j700 "$stage/missing" 2>/dev/null; then exit 1; fi
passed=$((passed + 1))
echo "passed $passed checks including exact J700 selector"
