Name:           service-manager
Version:        1.0
Release:        1%{?dist}
Summary:        Utility for monitoring and managing user system services
License:        GPLv3+
URL:            https://mirea.ru
Source0:        service-manager-%{version}.tar.gz
BuildArch:      noarch

Requires:       bash
Requires:       systemd

%description
Utility for monitoring and managing system services at user level.
Developed as coursework for "Operating System Security".

%prep
%setup -q -n %{name}-%{version}

%build
echo "Building..."

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/etc/systemd/user

install -m 755 src/service-manager.sh %{buildroot}/usr/local/bin/service-manager
install -m 644 systemd/service-manager.service %{buildroot}/etc/systemd/user/

%files
/usr/local/bin/service-manager
/etc/systemd/user/service-manager.service

%changelog
* Mon Dec 08 2025 Smirnov M.D. <user-12-47> - 1.0-1
- Initial release
