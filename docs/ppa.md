---
parent: Documentation
nav_order: 3
---

# Personal Package Archive

Stable upstream LTSP releases are offered in .deb package format in the [LTSP PPA](https://launchpad.net/~ltsp/+archive/ubuntu/ppa). They should work in all .deb-based distributions that use systemd, i.e. from Debian Jessie and Ubuntu 16.04 and upwards.

Currently, LTSP19+ packages aren't available in distributions, so this PPA is the only source for LTSP packages. But even when distributions do get LTSP, it's still recommended to have this PPA in your sources: when clients netboot, `ltsp init` dynamically configures a lot of other packages, like systemd, network-manager, display managers, netplan etc. Some times normal distribution updates of said packages break the netboot process, and urgent LTSP updates are required to fix it.

To install the repository in Ubuntu-based distributions, run as root:

```shell
add-apt-repository ppa:ltsp
apt update
```

To install the repository in Debian-based distributions, run as root:
```shell
wget https://ltsp.org/misc/ltsp-ubuntu-ppa-bionic.list -O /etc/apt/sources.list.d/ltsp-ubuntu-ppa-bionic.list
wget https://ltsp.org/misc/ltsp_ubuntu_ppa.gpg -O /etc/apt/trusted.gpg.d/ltsp_ubuntu_ppa.gpg
apt update
```
Note that normally Debian users should not be using PPAs. LTSP is an exception, as it only contains shell code (and a bit of python), it is interpreted (Architecture:all, no compiled binaries involved), and the .debs are tested on Debian too.
