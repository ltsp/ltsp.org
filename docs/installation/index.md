---
title: Installation
parent: Documentation
nav_order: 2
has_children: true
has_toc: false
---

# Installation

> 📝 **Note** for LTSP5 users: it's possible to install the new LTSP in parallel with LTSP5, with the exception of the /etc/dnsmasq.d/ltsp-server-dnsmasq.conf file, which will need to be deleted before generating a new one with `ltsp dnsmasq`.

All of the terminal commands in the wiki should be run as root, which means
you should initially run `sudo -i` on Ubuntu or `su -` on Debian.

## Server OS installation

The LTSP server can be headless, but it's usually better to install the
operating system using a "desktop" .iso and not a "server" one.
All desktop environments should work fine, but MATE and GNOME
receive the most testing.
Any .deb-based distribution that uses systemd should work;
i.e. from Ubuntu 16.04 and Debian Jessie and onward.

In case you end up choosing
[Ubuntu MATE 20.04](http://cdimage.ubuntu.com/ubuntu-mate/releases/20.04/release/ubuntu-mate-20.04.1-desktop-amd64.iso),
[@alkisg](https://github.com/alkisg) suggests running the following commands
after installation, to save some RAM for older clients:

```shell
apt purge --yes --auto-remove indicator-application mate-hud snapd
apt install --yes synaptic
```

## Adding the LTSP PPA

The LTSP PPA is where stable upstream LTSP releases are published.
It's mandatory for distributions before 2020 that have the older LTSP5,
and optional but recommended to have in newer distributions.
Follow the [ppa page](../ppa) to add it to your sources, then continue reading here.

## Installing LTSP server packages

The usual way to transform a normal installation into an LTSP server is to run:

```shell
apt install --install-recommends ltsp ltsp-binaries dnsmasq nfs-kernel-server openssh-server squashfs-tools ethtool net-tools epoptes
gpasswd -a administrator epoptes
```

Replace _administrator_ with the administrator username.
If you're not using the PPA, also replace `ltsp-binaries` with `ipxe`.
Description of the aforementioned packages:
 * ltsp: contains the LTSP code, it's common for both LTSP servers
   and LTSP clients.
 * ltsp-binaries: contains iPXE and memtest binaries.
 * dnsmasq: provides TFTP and optionally (proxy)DHCP and DNS services.
   Possible alternatives are isc-dhcp-server and tftpd-hpa, but only dnsmasq
   can do proxyDHCP, so it's the recommended default.
 * nfs-kernel-server: exports the virtual client disk image over NFS.
 * openssh-server: allows clients to authenticate and access /home via SSHFS.
 * ethtool, net-tools: allow disabling Ethernet flow control, to improve
   LAN speed when the server is gigabit and some clients are 100 Mbps.
 * [epoptes](https://epoptes.org/): optional; allows client monitoring and
   remote control; the gpasswd command allows the sysadmin to run epoptes.

All those packages can also be displayed with `apt show ltsp | grep ^Suggests`.

## Network configuration

There are two popular methods to configure LTSP networking. One is to
avoid any configuration; this usually means that you have a single NIC
on the LTSP server and an external DHCP server, for example a router,
pfsense, or a Windows server. In this case, run the following command:

```shell
ltsp dnsmasq
```

Another method is to have a dual NIC LTSP server, where one NIC is connected
to the normal network where the Internet is, and the other NIC is connected
to a separate switch with just the LTSP clients. For this method to work
automatically, assign a static IP of 192.168.67.1 to the internal NIC using
Network Manager or whatever else your distribution has, and run:

```shell
ltsp dnsmasq --proxy-dhcp=0
```

You can read about more `ltsp dnsmasq` options, like --dns or --dns-servers, in
its [man page](../../man/ltsp-dnsmasq).

## Maintaining a client image

LTSP supports three methods to maintain a client image. They are documented in
the [ltsp image](../../man/ltsp-image)
man page. You can use either one or all of them. In short, they are:
 * Chrootless (previously pnp): use the server root (/) as the template for
   the clients. It's the easiest method if it suits your needs, as you maintain
   only one operating system, not two (server and image).
 * Raw virtual machine image: graphically maintain e.g. a VirtualBox VM.
 * Chroot: manually maintain a [chroot directory](https://github.com/ltsp/ltsp/wiki/chroots) using console commands.

In the virtual machine and chroot cases, you're supposed to install the ltsp
package to the image, by adding the LTSP PPA and running
`apt install --install-recommends ltsp epoptes-client`, without specifying any other services.
In the chrootless and virtual machine cases, if you're using separate
partitions for some directories like /boot or /var, see the `ltsp image`
man page [EXAMPLES section](../../man/ltsp-image/#examples) for how to include them.
When the image is ready, to export it in _squashfs_ format and make it
available to the clients over NFS, run the following commands.

For chrootless:

```shell
ltsp image /
```

Virtual machines need to be symlinked before running `ltsp image`:

```shell
ln -s "/home/user/VirtualBox VMs/debian/debian-flat.vmdk" /srv/ltsp/debian.img
ltsp image debian
```

For a chroot in /srv/ltsp/x86_32:

```shell
ltsp image x86_32
```

You need to run these commands every time you install new software or updates
to your image and want to export its updated version.

## Configuring iPXE

After you create your initial image, or if you ever create additional images, run the following command to generate an iPXE menu and copy the iPXE binaries in TFTP:

```shell
ltsp ipxe
```

In LTSP5, syslinux was used, but iPXE replaced it as it's much more powerful.
You can read more about it in the [ltsp ipxe man page](../../man/ltsp-ipxe).


## NFS server configuration

To configure the LTSP server to serve the images or chroots over NFS, run:

```shell
ltsp nfs
```

For finetuning options, see the [ltsp nfs man page](../../man/ltsp-nfs).

## Generate ltsp.img

A new procedure that wasn't there in LTSP5 is provided by the following command:

```shell
ltsp initrd
```

This compresses /usr/share/ltsp, /etc/ltsp, /etc/{passwd,group} and the
server public SSH keys into /srv/tftp/ltsp/ltsp.img,
which is transferred as an "additional initrd" to the clients when they boot.
You can read about its benefits in its
[man page](../../man/ltsp-initrd),
for now keep in mind that you need to run `ltsp initrd` after each LTSP
package update, or when you add new users, or if you create or modify
[/etc/ltsp/ltsp.conf](../../man/ltsp.conf),
which replaced the LTSP 5 "lts.conf".

## Questions

Questions? Start a [discussion](https://github.com/ltsp/ltsp/discussions)
or come to the [online chat room](../advanced/chat-room).
