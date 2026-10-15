# aurora-neo-platform-config

Platform configuration for the Apple MacBook Neo (J700) running an Aurora
Silicon kernel:

- NetworkManager keeps the permanent Wi-Fi address for scans and connections on
  the `mt7932-fullmac` driver.
- A dracut module puts the Apple display driver (`appledrm`) in the initramfs
  and loads it before udev coldplug, so a USB-C external display shows the boot
  console and the disk passphrase prompt with the lid closed.

## Radio

The kernel brings the MT7932 Wi-Fi and Bluetooth functions up: the board device
tree enables the radio bootstrap, udev loads the drivers, and cfg80211 reads
`regulatory.db`. Firmware and per-unit calibration are required and are not
included in this package.

The regulatory domain comes from wireless-regdb's `setregdomain`: set
`COUNTRY=XX` in `/etc/sysconfig/regdomain`, or leave it unset to derive the
country from the time zone.

## External display in the initramfs

The USB-C external display is driven by the second display coprocessor
(DCPEXT). The `appledrm` module drives it, and it also provides the Type-C
display route that the port controller (`sn201202x`) waits for before it
switches the port to DisplayPort. Until `appledrm` loads, the external display
stays dark. If the module is missing from the initramfs, it stays dark until
the root file system is unlocked and mounted.

`90aurora-neo-display` installs `appledrm` even in host-only images, and its
unit `aurora-neo-display-early.service` loads it at `sysinit.target` on a J700.
Other machines are left to udev, and a failed load never blocks the boot.

The module is enabled by `/usr/lib/dracut/dracut.conf.d/50-aurora-neo-display.conf`.
It takes effect when the initramfs is next rebuilt, for example with
`dracut -f --regenerate-all`. To opt out, add `omit_dracutmodules+=" aurora-neo-display "`
to a file in `/etc/dracut.conf.d/`.

## Install

Install the Fedora RPM, or run `make install` as root. The installed files are
`/usr/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf`,
`/usr/lib/dracut/modules.d/90aurora-neo-display/` and
`/usr/lib/dracut/dracut.conf.d/50-aurora-neo-display.conf`. Rebuild the
initramfs and reboot to apply the configuration. To override it, place a configuration file under
`/etc/NetworkManager/conf.d/`.

System sleep, lid and
power-button settings follow the distribution and the user's configuration.

## Build

```sh
make check
make install DESTDIR=/tmp/root
rpmbuild -ba aurora-neo-platform-config.spec
```

For an RPM build, put a source archive named
`aurora-neo-platform-config-0.2.0.tar.gz` in the RPM `SOURCES` directory, with a
matching top-level directory.

## License

MIT, see `LICENSE`.
