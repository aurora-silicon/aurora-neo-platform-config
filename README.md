# aurora-neo-platform-config

Platform configuration for the Apple MacBook Neo (J700) running an Aurora
Silicon kernel. The package keeps the permanent Wi-Fi address for scans and
connections on the `mt7932-fullmac` driver, and sets up libinput for the
trackpad.

## Radio

The kernel brings the MT7932 Wi-Fi and Bluetooth functions up: the board device
tree enables the radio bootstrap, udev loads the drivers, and cfg80211 reads
`regulatory.db`. Firmware and per-unit calibration are required and are not
included in this package.

The regulatory domain comes from wireless-regdb's `setregdomain`: set
`COUNTRY=XX` in `/etc/sysconfig/regdomain`, or leave it unset to derive the
country from the time zone.

## Trackpad

The kernel reports the trackpad's palms as `MT_TOOL_PALM`, from the
controller's own classification and the contact's tool area. libinput's Apple
MTP entry also rejects any touch larger than 1600 as a palm; on the J700 a
flat thumb reaches that size while a small palm stays below it, so that
threshold rejects thumbs and lets palms through. The quirk turns size-based
palm detection off for this trackpad. `libinput quirks list /dev/input/eventN`
shows it applied.

## Install

Install the Fedora RPM, or run `make install` as root. The installed files are
`/usr/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf` and
`/usr/share/libinput/60-aurora-neo-j700.quirks`. Reboot to apply the
configuration. To override them, place a configuration file under
`/etc/NetworkManager/conf.d/`, or a section in
`/etc/libinput/local-overrides.quirks`.

This package contains only the Wi-Fi address policy and the trackpad quirk.
System sleep, lid and power-button settings follow the distribution and the
user's configuration.

## Build

```sh
make check
make install DESTDIR=/tmp/root
rpmbuild -ba aurora-neo-platform-config.spec
```

For an RPM build, put a source archive named
`aurora-neo-platform-config-0.1.0.tar.gz` in the RPM `SOURCES` directory, with a
matching top-level directory.

## License

MIT, see `LICENSE`.
