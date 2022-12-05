# Snap

There's some controversy regarding [snap](https://snapcraft.io/), Ubuntu's new
packaging format. LTSP does its best to support it, but occasionally some
issues arise with it that can't be solved from the LTSP side, for example
[wasting RAM in live sessions](https://bugs.launchpad.net/bugs/1867415)
or [not working with NFS home](https://bugs.launchpad.net/bugs/1662552).

If you decide to remove snap, you may open a terminal, type `sudo -i` to become
root, and then copy/paste all the following code:

```shell

re() {
    if ! "$@"; then
        echo "Command failed: $*" >&2
        exit 1
    fi
}

remove_snap() {
    local packages

    if [ -x /usr/bin/mate-session ]; then
        packages=$(dpkg-query -W -f='${Package} ${Version}\n' arctica-greeter-guest-session ayatana-indicator-application evolution-common indicator-application mate-hud 2>/dev/null | awk '$2 { print $1 }') || true
        if [ -n "$packages" ]; then
            echo "Removing some MATE cruft: $packages"
            re apt-get purge --yes --auto-remove $packages
        fi
    fi
    if [ -x /usr/bin/snap ]; then
        if [ -f /var/lib/snapd/desktop/applications/firefox_firefox.desktop ] &&
            [ ! -L /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]; then
            echo "Replacing Firefox snap with deb using MozillaTeam PPA"
            # Remove firefox before snapd to work around LP: #1998710
            snap remove firefox 2>/dev/null || true
            re add-apt-repository --yes ppa:mozillateam/ppa
            echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001' >/etc/apt/preferences.d/60mozillateam-ppa
            # If you need more locales e.g. firefox-locale-el add them in this line
            re apt-get install --yes firefox firefox-locale-en
            if [ -f /usr/share/mate/applications/firefox.desktop ]; then
                re dpkg-divert --package sch-scripts --divert \
                    /usr/share/mate/applications/firefox-desktop.diverted \
                    --rename /usr/share/mate/applications/firefox.desktop
            fi
        fi
        # Remove snapd, THEN provide a symlink to deb firefox for panels etc
        re apt-get purge --yes --auto-remove snapd
        if [ ! -e /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]; then
            re mkdir -p /var/lib/snapd/desktop/applications
            re ln -s /usr/share/applications/firefox.desktop /var/lib/snapd/desktop/applications/firefox_firefox.desktop
        fi
    fi
}

remove_snap
```
