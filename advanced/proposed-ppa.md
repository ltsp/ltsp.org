---
parent: Advanced topics
---

# Proposed PPA

See also: [LTSP PPA documentation](/docs/ppa).

LTSP releases are normally published in the [LTSP proposed PPA](https://launchpad.net/~ltsp/+archive/ubuntu/proposed) and after a few days, if noone complains about regressions, they are copied to the [LTSP PPA](https://launchpad.net/~ltsp/+archive/ubuntu/ppa).
That means that most LTSP administrators should have the proposed PPA in some test installation or in their personal computers etc, to be able to test new releases and file issues before they reach their production setups.

To install the repository in Ubuntu-based distributions, run as root:

```shell
add-apt-repository ppa:ltsp/proposed
apt update
```

To install the repository in Debian-based distributions, run as root:

```shell
wget https://ltsp.org/misc/ltsp-ubuntu-proposed-focal.list -O /etc/apt/sources.list.d/ltsp-ubuntu-proposed-focal.list
wget https://ltsp.org/misc/ltsp_ubuntu_ppa.gpg -O /etc/apt/trusted.gpg.d/ltsp_ubuntu_ppa.gpg
apt update
```
