---
parent: Installation
grand_parent: Documentation
nav_order: 1
---

# Raspberry Pi OS

Basic installation instructions for netbooting Raspberry Pi clients from a Raspberry Pi OS (formely Raspbian) chroot on an LTSP server.

## Prerequisites

The LTSP server should already be configured by following the [installation page](../). If booting x86 clients is also required, do that part first as it's easier.

## Client configuration

The client configuration is officially documented [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/net_tutorial.md). In short:

 - To netboot Pi 2, format an SD card with the fat file system and put only bootcode.bin in it. This file can be found in /boot/bootcode.bin inside your Raspberry Pi OS image.
 - For Pi 3B, boot from an SD card, run `echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt` and reboot.
 - Pi 3B+ supports netbooting out of the box.
 - For Pi 4 and Pi 400, boot from a fully updated SD card to get the latest firmware, then run `sudo raspi-config` and select `Advanced Options > Boot Order > Network Boot`.

## Chroot preparation

Raspberry Pi OS is very optimized for Raspberries, so it's currently a better option than e.g. Ubuntu MATE or other distributions. The easiest way to generate a Raspberry Pi OS chroot isn't with the `debootstrap` command, but by [downloading an image](https://www.raspberrypi.org/software/operating-systems/). You may also follow the [Raspberry Pi OS installation guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) or you may use `dd` to read the SD card from an existing Raspberry Pi installation; to keep the instructions shorter, we assume that in the end you have an uncompressed raspios.img on the LTSP server.

```shell
losetup -rP /dev/loop8 2020-12-02-raspios-buster-armhf-full.img
mount -o ro /dev/loop8p2 /mnt
time cp -a /mnt/. /srv/ltsp/raspios
umount /mnt
mount -o ro /dev/loop8p1 /mnt
cp -a /mnt/. /srv/ltsp/raspios/boot/
umount /mnt
losetup -d /dev/loop8
```

At this point, Raspberry Pi OS should be in `/srv/ltsp/raspios`. This chroot isn't ready for netbooting yet, the following commands are needed:

```shell
# Go to the chroot in order to use relative directories
cd /srv/ltsp/raspios
# Mask services that we don't want in netbooting
systemctl mask --root=. dhcpcd dphys-swapfile raspi-config resize2fs_once
# Remove SD card entries from fstab
echo 'proc            /proc           proc    defaults          0       0' >./etc/fstab
# Use an appropriate cmdline for NFS_RW netbooting
echo 'ip=dhcp root=/dev/nfs rw nfsroot=192.168.67.1:/srv/ltsp/raspios,vers=3,tcp,nolock console=serial0,115200 console=tty1 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles modprobe.blacklist=bcm2835_v4l2' >./boot/cmdline.txt
```

## Server preparation

In ltsp.conf, set RPI_IMAGE to the chroot name. This will be used by `ltsp kernel` to generate the appropriate symlinks from `/srv/tftp/*` to `/srv/ltsp/raspios/boot/*`.

```shell
[server]
RPI_IMAGE="raspios"
```

Then, run:

```shell
ltsp kernel raspios
ltsp initrd
ltsp nfs
```

## NFS_RW netbooting

At this point we're ready to netboot a single client in NFS_RW mode. This means that whatever changes we do on that client, like installing new programs, are directly saved in /srv/ltsp/raspios.

First, export the chroot in NFS read-write mode:

```shell
echo '/srv/ltsp/raspios  *(rw,async,crossmnt,no_subtree_check,no_root_squash,insecure)' >/etc/exports.d/ltsp-raspios.exports
exportfs -ra
```

You may replace `*` with an IP to only allow access to a single client, or you may delete the /etc/exports.d/ltsp-raspios.exports file when you're done, so that there are no security issues.

Now boot a single client, [add the LTSP PPA](../../ppa/) to your sources, and install the client-side packages:

```shell
apt install --install-recommends ltsp epoptes-client
```

## LTSP mode netbooting

At this point our chroot contains the LTSP code and is ready to be netbooted. But it needs a different kernel cmdline than the NFS_RW mode, so run the following commands:

```shell
echo 'ip=dhcp root=/dev/nfs nfsroot=192.168.67.1:/srv/ltsp/raspios,vers=3,tcp,nolock init=/usr/share/ltsp/client/init/init ltsp.image=images/raspios.img console=serial0,115200 console=tty1 elevator=deadline fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles modprobe.blacklist=bcm2835_v4l2' >/srv/ltsp/raspios/boot/cmdline.txt

# Finally, create the squashfs image
ltsp image raspios --mksquashfs-params='-comp lzo'
```

That's it, now you should be able to netboot all your Raspberry Pi clients.
