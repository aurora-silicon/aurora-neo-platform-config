Name:           aurora-neo-platform-config
Version:        0.1.0
Release:        4%{?dist}
Summary:        Platform configuration for the Apple MacBook Neo (J700)
License:        MIT
URL:            https://github.com/aurora-silicon/aurora-neo-platform-config
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  make
Recommends:     NetworkManager-wifi

%description
NetworkManager configuration for the MacBook Neo (J700): keeps the Wi-Fi
station address fixed on mt7932-fullmac. Firmware and per-unit calibration
are not included.

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

%changelog
* Sun Oct 11 2026 Ryan Murray <ryan@aurorasilicon.org> - 0.1.0-4
- Keep only the NetworkManager Wi-Fi address policy.
