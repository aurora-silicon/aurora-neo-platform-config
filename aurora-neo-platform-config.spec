Name:           aurora-neo-platform-config
Version:        0.2.0
Release:        1%{?dist}
Summary:        Platform configuration for the Apple MacBook Neo (J700)
License:        MIT
URL:            https://github.com/aurora-silicon/aurora-neo-platform-config
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  make
Recommends:     NetworkManager-wifi
Requires:       dracut

%description
Platform configuration for the MacBook Neo (J700): keeps the Wi-Fi station
address fixed on mt7932-fullmac, and a dracut module that brings the Apple
display driver up early so a USB-C external display shows the boot console
and the disk passphrase prompt with the lid closed. Firmware and per-unit
calibration are not included.

%prep
%autosetup

%build

%install
%make_install PREFIX=%{_prefix}

%check
sh tests/run.sh

%files
%license LICENSE
%doc README.md
%{_prefix}/lib/NetworkManager/conf.d/80-aurora-neo-mt7932.conf
%dir %{_prefix}/lib/dracut/modules.d/90aurora-neo-display
%{_prefix}/lib/dracut/modules.d/90aurora-neo-display/module-setup.sh
%{_prefix}/lib/dracut/modules.d/90aurora-neo-display/aurora-neo-display-early.sh
%{_prefix}/lib/dracut/modules.d/90aurora-neo-display/aurora-neo-display-early.service
%{_prefix}/lib/dracut/dracut.conf.d/50-aurora-neo-display.conf

%changelog
* Thu Oct 15 2026 Ryan Murray <ryan@aurorasilicon.org> - 0.2.0-1
- Add the aurora-neo-display dracut module: appledrm in the initramfs, loaded
  early on the J700, so a USB-C external display works at the passphrase prompt.

* Sun Oct 11 2026 Ryan Murray <ryan@aurorasilicon.org> - 0.1.0-4
- Keep only the NetworkManager Wi-Fi address policy.
