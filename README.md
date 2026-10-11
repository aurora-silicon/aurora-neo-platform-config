# aurora-neo-platform-config

NetworkManager configuration for the Apple MacBook Neo (J700) running an
Aurora Silicon kernel. The package keeps the permanent Wi-Fi address for scans
and connections on the `mt7932-fullmac` driver.

## Radio

The kernel brings the MT7932 Wi-Fi and Bluetooth functions up: the board device
tree enables the radio bootstrap, udev loads the drivers, and cfg80211 reads
`regulatory.db`. Firmware and per-unit calibration are required and are not
included in this package.

The regulatory domain comes from wireless-regdb's `setregdomain`: set
`COUNTRY=XX` in `/etc/sysconfig/regdomain`, or leave it unset to derive the
country from the time zone.

## Install

Install the Fedora RPM, or run `make install` as root. The installed file is
`/usr/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf`. Reboot to apply the
configuration. To override it, place a configuration file under
`/etc/NetworkManager/conf.d/`.

This package contains only the Wi-Fi address policy. System sleep, lid and
power-button settings follow the distribution and the user's configuration.

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
