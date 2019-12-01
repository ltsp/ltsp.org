---
parent: Documentation
nav_order: 2
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

### Optional

#### The following packages come with some distributions and can be removed to increase performance:
  - *indicator-application* - Removing this package makes the system tray more simplistic by disabling features such as system tray icons that change their appearance, for example, a CPU monitor system tray widget displaying the CPU load. This package has been known to hog the CPU and removing it has no effect on the functionality of the applications that use the system tray.
  - *mate-hud* - Not necessary unless you want a hud. Has also been reported to be unstable.
  - *snapd* - Allows installing [snap packages](snapcraft.io). This package slows boot times slightly and can use a lot of RAM. If you are planning to use snap packages be wary of possible pitfalls, for example, snap packages if installed in a certain way become accessible only by the user that installed the package.

To remove all of these packages run:
```shell
apt purge --yes --auto-remove indicator-application mate-hud snapd
```

#### It is also recommended to install synaptic, a versatile package manager:
```shell
apt install --yes synaptic
```

## Adding the LTSP PPA

The LTSP PPA is where stable upstream LTSP releases are published.
Currently it's mandatory, as distributions still have the older LTSP5,
later on it will be optional but recommended to have. Follow the [ppa
page](../ppa) to add it to your sources, then continue reading here.

## Installing LTSP server packages

The usual way to transform a normal installation into an LTSP server is to run:

```shell
apt install ltsp ltsp-binaries dnsmasq nfs-kernel-server openssh-server squashfs-tools ethtool net-tools epoptes
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
its [man page](https://ltsp.org/man/ltsp-dnsmasq).

## Maintaining a client image

LTSP supports three methods to maintain a client image. They are documented in
the [ltsp image](https://ltsp.org/man/ltsp-image)
man page. You can use either one or all of them. In short, they are:
 * Chrootless (previously pnp): use the server root (/) as the template for
   the clients. It's the easiest method if it suits your needs, as you maintain
   only one operating system, not two (server and image).
 * Raw virtual machine image: graphically maintain e.g. a VirtualBox VM.
 * Chroot: maintain a chroot directory using console commands. Note that the
   LTSP5 `ltsp-build-client` command is no longer supported, see the
   [man page](https://ltsp.org/man/ltsp-image).

In the virtual machine and chroot cases, you're supposed to install the ltsp
package to the image, by adding the LTSP PPA and running
`apt install ltsp epoptes-client`, without specifying any other services.
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
You can read more about it in the [ltsp ipxe man page](https://ltsp.org/man/ltsp-ipxe).


## NFS server configuration

To configure the LTSP server to serve the images or chroots over NFS, run:

```shell
ltsp nfs
```

For finetuning options, see the [ltsp nfs man page](https://ltsp.org/man/ltsp-nfs).

## Generate ltsp.img

A new procedure that wasn't there in LTSP5 is provided by the following command:

```shell
ltsp initrd
```

This compresses /usr/share/ltsp, /etc/ltsp, /etc/{passwd,group} and the
server public SSH keys into /srv/tftp/ltsp/ltsp.img,
which is transferred as an "additional initrd" to the clients when they boot.
You can read about its benefits in its
[man page](https://ltsp.org/man/ltsp-initrd),
for now keep in mind that you need to run `ltsp initrd` after each LTSP
package update, or when you add new users, or if you create or modify
[/etc/ltsp/ltsp.conf](https://ltsp.org/man/ltsp.conf),
which replaced the LTSP 5 "lts.conf".

## Questions

Questions? Open a [discussion issue](https://github.com/ltsp/community/issues)
or come to [IRC live chat](http://ts.sch.gr/repo/irc).
