Name:           mdd
Version:        %{pkg_version}
Release:        1%{?dist}
Summary:        Mammal Diversity Database desktop application
License:        MIT
URL:            https://github.com/mammaldiversity/mdd_app

%description
Mammal Diversity Database desktop application.

%prep
# Prebuilt bundle, no prep needed

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/mdd
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/512x512/apps

cp -r %{_sourcedir}/bundle/* %{buildroot}/opt/mdd/
cp %{_sourcedir}/favicon512.png %{buildroot}/usr/share/icons/hicolor/512x512/apps/mdd.png
cp %{_sourcedir}/mdd.desktop %{buildroot}/usr/share/applications/mdd.desktop

ln -sf /opt/mdd/mdd %{buildroot}/usr/bin/mdd

%files
/opt/mdd/
/usr/bin/mdd
/usr/share/applications/mdd.desktop
/usr/share/icons/hicolor/512x512/apps/mdd.png

%changelog
