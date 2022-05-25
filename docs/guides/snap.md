# Snap

There's some controversy regarding [snap](https://snapcraft.io/), Ubuntu's new
packaging format. LTSP does its best to support it, but occasionally some
issues arise with it that can't be solved from the LTSP side, for example
[wasting RAM in live sessions](https://bugs.launchpad.net/bugs/1867415)
or [not working with NFS home](https://bugs.launchpad.net/bugs/1662552).

If you decide to remove snap, you may open a terminal, type `sudo -i` to become
root, and then copy/paste all the following code:

```shell
test -x /usr/bin/snap || exit 0
if [ -f /var/lib/snapd/desktop/applications/firefox_firefox.desktop ] &&
    [ ! -L /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]; then
    snapff=1
fi
apt-get purge --yes --auto-remove ayatana-indicator-application \
    indicator-application mate-hud snapd
if [ "$snapff" = 1 ]; then
    # If firefox snap was installed, replace it with the .deb from the PPA
    add-apt-repository --yes ppa:mozillateam/ppa
    echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001' >/etc/apt/preferences.d/60mozillateam-ppa
    # If you need more locales e.g. firefox-locale-el add them in this line
    apt-get install --yes firefox firefox-locale-en
    # Work around https://bugs.launchpad.net/bugs/1967736
    if [ -f /usr/share/mate/applications/firefox.desktop ]; then
        dpkg-divert --package sch-scripts --divert \
            /usr/share/mate/applications/firefox-desktop.diverted \
            --rename /usr/share/mate/applications/firefox.desktop
        if [ ! -e /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]
        then
            mkdir -p /var/lib/snapd/desktop/applications
            ln -s /usr/share/applications/firefox.desktop \
                /var/lib/snapd/desktop/applications/firefox_firefox.desktop
        fi
    fi
fi
```
