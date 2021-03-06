#!/bin/sh

set -x

if [ ! -d repo ]; then
   ostree init --repo=repo --mode=archive-z2
fi

rm -rf firefox
xdg-app build-init -v org.fedoraproject.Sdk.Var firefox org.fedoraproject.firefox org.fedoraproject.Sdk org.fedoraproject.Platform 22

rm -rf rpms
mkdir rpms
(cd rpms; xdg-app build --share=network ../firefox dnf download --resolve firefox)
xdg-app build firefox ./extract-rpms.sh rpms/*.rpm

# Change /usr in the wrapper shell script
sed -i s#/usr#/app#g firefox/files/bin/firefox

# Rename desktop file and icon to have app-id prefix
mv firefox/files/share/applications/firefox.desktop firefox/files//share/applications/org.fedoraproject.firefox.desktop
sed -i s#Icon=firefox#Icon=org.fedoraproject.firefox#g firefox/files/share/applications/org.fedoraproject.firefox.desktop
for i in firefox/files/share/icons/hicolor/*/apps/firefox.png; do
    mv $i `echo $i | sed s/firefox.png/org.fedoraproject.firefox.png/`;
done

xdg-app build-finish --command=firefox --socket=x11 --filesystem=xdg-download --persist=.mozilla --share=ipc --socket=pulseaudio --share=network firefox
xdg-app build-export repo firefox
