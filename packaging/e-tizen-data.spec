%define alias e-tizen-data

Name:          e-tizen-data-profile_wearable
Version:       0.4.18
Release:       0
Provides:      e-tizen-data = %{version}-%{release}
BuildArch:     noarch
Summary:       Enlightenment data files
Group:         Graphics & UI Framework/Other
License:       BSD-2-Clause
Source0:       %{name}-%{version}.tar.gz
Source1001:    %{alias}.manifest
BuildRequires: pkgconfig(eet)
BuildRequires: pkgconfig(edje)
BuildRequires: eet-bin
BuildRequires: edje-tools
BuildRequires: xkb-tizen-data
Requires:      enlightenment
Requires:      e-mod-tizen-wm-policy
Requires:      e-mod-tizen-devicemgr
Requires:      e-mod-tizen-keyrouter
Requires:      e-mod-tizen-wl-textinput
Requires:      e-mod-tizen-processmgr
Requires:      e-mod-tizen-gesture
Requires:      e-mod-tizen-screen-reader
Requires:      xkeyboard-config

%{!?TZ_SYS_RO_SHARE: %global TZ_SYS_RO_SHARE /usr/share}

%description
Data and configuration files for enlightenment

%prep
%setup -q
cp -a %{SOURCE1001} .

export TZ_SYS_RO_SHARE="%{TZ_SYS_RO_SHARE}"
default/config/tizen-wearable/make_keymap_conf.sh

%build
%autogen
%configure  \
    --with-systemdunitdir=%{_unitdir} \
    --with-engine=gl \
    --disable-skip-first-damage \
    --prefix=%{TZ_SYS_RO_SHARE}/enlightenment
make

%install
rm -rf %{buildroot}

%__mkdir_p %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/config/tizen-wearable
%__mkdir_p %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/backgrounds
%__mkdir_p %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/themes
%__mkdir_p %{buildroot}/%{TZ_SYS_RO_SHARE}/upgrade/scripts
%__mkdir_p %{buildroot}/%{_sysconfdir}/dbus-1/system.d
%__mkdir_p %{buildroot}/%{_bindir}
%__mkdir_p %{buildroot}/%{TZ_SYS_RO_SHARE}/tdm
%__cp -afr data/scripts/winsys_upgrade.sh %{buildroot}/%{TZ_SYS_RO_SHARE}/upgrade/scripts/500.winsys_upgrade.sh
%__cp -afr default/config/*.cfg          %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/config
%__cp -afr default/config/tizen-wearable/*.cfg %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/config/tizen-wearable
%__cp -afr default/backgrounds/*.edj     %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/backgrounds
%__cp -afr default/themes/*.edj     %{buildroot}/%{TZ_SYS_RO_SHARE}/enlightenment/data/themes
%__cp -afr data/scripts/keymap_update.sh %{buildroot}/%{_bindir}
%__cp -afr data/scripts/enlightenment_mon.sh %{buildroot}/%{_bindir}
%__cp -afr data/dbus/org.enlightenment.wm.conf %{buildroot}/%{_sysconfdir}/dbus-1/system.d
%__cp -afr data/tdm/tdm.ini %{buildroot}/%{TZ_SYS_RO_SHARE}/tdm

%define daemon_user display
%define daemon_group display

# install service
%__mkdir_p %{buildroot}%{_unitdir}
install -m 644 data/units/display-manager.service %{buildroot}%{_unitdir}
install -m 644 data/units/display-manager-monitor.service %{buildroot}%{_unitdir}

%__mkdir_p %{buildroot}%{_unitdir_user}
install -m 644 data/units/enlightenment-user.service %{buildroot}%{_unitdir_user}

# install env file for service
%__mkdir_p %{buildroot}%{_sysconfdir}/sysconfig
install -m 0644 data/units/enlightenment %{buildroot}%{_sysconfdir}/sysconfig

# install enlightenment.sh
%__mkdir_p %{buildroot}%{_sysconfdir}/profile.d
install -m 0644 data/units/enlightenment.sh %{buildroot}%{_sysconfdir}/profile.d

%pre
# create groups 'display'
getent group %{daemon_group} >/dev/null || %{_sbindir}/groupadd -r -o %{daemon_group}

# create user 'display'
getent passwd %{daemon_user} >/dev/null || %{_sbindir}/useradd -r -g %{daemon_group} -d /run/display -s /bin/false -c "Display daemon" %{daemon_user}

# setup display manager service
%__mkdir_p %{_unitdir}/graphical.target.wants/
ln -sf ../display-manager.service %{_unitdir}/graphical.target.wants/display-manager.service
ln -sf ../display-manager-monitor.service %{_unitdir}/graphical.target.wants/display-manager-monitor.service

%__mkdir_p %{_unitdir_user}/basic.target.wants
ln -sf ../enlightenment-user.service %{_unitdir_user}/basic.target.wants/enlightenment-user.service

rm -rf %{_localstatedir}/lib/enlightenment

%postun
rm -f %{_unitdir}/graphical.target.wants/display-manager.service
rm -f %{_unitdir}/graphical.target.wants/display-manager-monitor.service
rm -f %{_unitdir_user}/basic.target.wants/enlightenment-user.service

%files
%manifest %{alias}.manifest
%defattr(-,root,root,-)
%license COPYING
%{TZ_SYS_RO_SHARE}/enlightenment/data
%{TZ_SYS_RO_SHARE}/enlightenment/data/backgrounds/*.edj
%{TZ_SYS_RO_SHARE}/enlightenment/data/themes/*.edj
%{TZ_SYS_RO_SHARE}/enlightenment/data/config/*.cfg
%{TZ_SYS_RO_SHARE}/enlightenment/data/config/tizen-wearable/*.cfg
%{TZ_SYS_RO_SHARE}/upgrade/scripts/500.winsys_upgrade.sh
%{_unitdir}/display-manager.service
%{_unitdir}/display-manager-monitor.service
%{_unitdir_user}/enlightenment-user.service
%config %{_sysconfdir}/sysconfig/enlightenment
%config %{_sysconfdir}/profile.d/enlightenment.sh
%config %{TZ_SYS_RO_SHARE}/tdm/tdm.ini
%{_bindir}/keymap_update.sh
%{_bindir}/enlightenment_mon.sh
%{_sysconfdir}/dbus-1/system.d/org.enlightenment.wm.conf
