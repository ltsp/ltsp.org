---
parent: Installation
grand_parent: Documentation
nav_order: 1
---

# Raspbian

Basic installation instructions for netbooting Raspberry Pi clients from a Raspbian chroot on an LTSP server.

> 📝 **Note**: LTSP authors do not have any Raspberry Pi LTSP installations, so they're only able to work on Raspberry Pi LTSP support when funding is found. Currently, a kind sponsor has partially funded code development and is successfully netbooting 200 Raspberries; but the process hasn't been fully automated nor the documentation proof-read. This means that currently you need to contact [alkisg](https://github.com/alkisg) for remote assistance for Raspberry Pi installations.

## Prerequisites

The LTSP server should already be configured by following the [installation page](https://ltsp.org/docs/installation). If booting x86 clients is also required, do that part first as it's easier.

## Client configuration

This method has been tested with Raspbery Pi 2, 3B+ and 4.

 - To netboot Pi 2, format an SD card with the fat file system and put only bootcode.bin in it. This file can be found in /boot/bootcode.bin inside your Raspbian image.
 - Pi 3B+ supports netbooting out of the box.
 - Pi 4 shipped without netbooting code, so it currently needs an eeprom update. I used `/lib/firmware/raspberrypi/bootloader/beta/pieeprom-2020-01-09.bin` and I followed the instructions from `/lib/firmware/raspberrypi/bootloader/raspberry_pi4_network_boot_beta.md`.

## Chroot preparation

Raspbian is very optimized for Raspberries, so it's currently a better option than e.g. Ubuntu MATE or other distributions. The easiest way to generate a Raspbian chroot isn't with the `debootstrap` command, but by [downloading Raspbian](https://www.raspberrypi.org/downloads/raspbian/). You may also follow the [Raspbian installation guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) or you may use `dd` to read the SD card from an existing Raspbian; to keep the instructions shorter, we assume that in the end you have an uncompressed raspbian.img on the LTSP server.

```shell
losetup -rP /dev/loop8 2019-09-26-raspbian-buster.img
mount -o ro /dev/loop8p2 /mnt
time cp -a /mnt/. /srv/ltsp/raspbian
umount /mnt
mount -o ro /dev/loop8p1 /mnt
cp -a /mnt/. /srv/ltsp/raspbian/boot/
umount /mnt
losetup -d /dev/loop8
```

At this point, Raspbian should be in `/srv/ltsp/raspbian`. This chroot isn't ready for netbooting yet, the following commands are needed:

```shell
# Go to the chroot in order to use relative directories
cd /srv/ltsp/raspbian
# Mask services that we don't want in netbooting
systemctl mask --root=. dhcpcd dphys-swapfile raspi-config resize2fs_once
# Remove SD card entries from fstab
echo 'proc            /proc           proc    defaults          0       0' >./etc/fstab
# Use an appropriate cmdline for NFS_RW netbooting
echo 'ip=dhcp root=/dev/nfs rw nfsroot=192.168.67.1:/srv/ltsp/raspbian,vers=3,tcp,nolock console=serial0,115200 console=tty1 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles modprobe.blacklist=bcm2835_v4l2' >./boot/cmdline.txt
```

## Server preparation

In ltsp.conf, set RPI_IMAGE to the chroot name. This will be used by `ltsp kernel` to generate the appropriate symlinks from `/srv/tftp/*` to `/srv/ltsp/raspbian/boot/*`.

```shell
[server]
RPI_IMAGE="raspbian"
```

Then, run:

```shell
ltsp kernel raspbian
ltsp initrd
ltsp nfs
```

## NFS_RW netbooting

At this point we're ready to netboot a single client in NFS_RW mode. This means that whatever changes we do on that client, like installing new programs, are directly saved in /srv/ltsp/raspbian.

First, export the chroot in NFS read-write mode:

```shell
echo '/srv/ltsp/raspbian  *(rw,async,crossmnt,no_subtree_check,no_root_squash,insecure)' >/etc/exports.d/ltsp-raspbian.exports
exportfs -ra
```

You may replace `*` with an IP to only allow access to a single client, or you may delete the /etc/exports.d/ltsp-raspbian.exports file when you're done, so that there are no security issues.

Now boot a single client, [add the LTSP PPA](https://ltsp.org/docs/ppa) to your sources, and install the client-side packages:

```shell
apt install --install-recommends ltsp epoptes-client
```

## LTSP mode netbooting

At this point our chroot contains the LTSP code and is ready to be netbooted. But it needs a different kernel cmdline than the NFS_RW mode, so run the following commands:

```shell
echo 'ip=dhcp root=/dev/nfs nfsroot=192.168.67.1:/srv/ltsp/raspbian,vers=3,tcp,nolock init=/usr/share/ltsp/client/init/init ltsp.image=images/raspbian.img console=serial0,115200 console=tty1 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles modprobe.blacklist=bcm2835_v4l2' >/srv/ltsp/raspbian/boot/cmdline.txt

# Finally, create the squashfs image
ltsp image raspbian --mksquashfs-params='-comp lzo'
```

That's it, now you should be able to netboot all your Raspberry Pi clients.

At your convenience, also check out some [common Raspbian issues](https://github.com/ltsp/community/issues/85).
