Name:           aurora-neo-platform-config
Version:        0.1.0
Release:        5%{?dist}
Summary:        Platform configuration for the Apple MacBook Neo (J700)
License:        MIT
URL:            https://github.com/aurora-silicon/aurora-neo-platform-config
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  make
BuildRequires:  grep
Requires:       grep
Recommends:     NetworkManager-wifi

%description
NetworkManager configuration for the MacBook Neo (J700): keeps the Wi-Fi
station address fixed on mt7932-fullmac. Firmware and per-unit calibration
are not included. An exact J700 board match supplies the native UPower
75/80 charge-limit policy.

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

%{_prefix}/lib/udev/rules.d/80-aurora-neo-charge-limit.rules

%changelog
* Mon Oct 12 2026 Ryan Murray <ryan@aurorasilicon.org> - 0.1.0-5
- Supply native UPower charge limits only for the J700 battery.
* Sun Oct 11 2026 Ryan Murray <ryan@aurorasilicon.org> - 0.1.0-4
- Keep only the NetworkManager Wi-Fi address policy.
