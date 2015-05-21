#!/bin/sh

if [ ! -d repo ]
   ostree init --repo=repo --mode=archive-z2
fi

rm -rf firefox
xdg-app build-init -v org.fedoraproject.Sdk.Var firefox org.fedoraproject.firefox org.fedoraproject.Sdk org.fedoraproject.Platform 22

rm -rf rpms
mkdir rpms
(cd rpms; xdg-app build --allow=network firefox dnf download --resolve firefox)
xdg-app build --allow=network firefox ./extract-rpms.sh rpms/*.rpm

# Change /usr in the wrapper shell script
sed -i s#/usr#/app#g /app/bin/firefox

# Rename desktop file and icon to have app-id prefix
mv /app/share/applications/firefox.desktop /app/share/applications/org.fedoraproject.firefox.desktop
sed -i s#Icon=firefox#Icon=org.fedoraproject.firefox#g /app/share/applications/org.fedoraproject.firefox.desktop
for i in /app/share/icons/hicolor/*/apps/firefox.png; do
    mv $i `echo $i | sed s/firefox.png/org.fedoraproject.firefox.png/`;
done

xdg-app build-finish --command=firefox --allow=x11 --allow=host-fs --allow=ipc --allow=pulseaudio --allow=network firefox
xdg-app build-export repo firefox
