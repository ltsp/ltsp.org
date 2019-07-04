---
parent: Documentation
nav_order: 4
---

# Netboot clients

To configure the LTSP clients to boot from the network with the PXE protocol, two methods are used, depending on whether the network card is onboard, in which case you should set appropriate BIOS/UEFI settings, or whether it's in a PCI or PCI-e slot, in which case you should install iPXE.

## BIOS/UEFI

To enable network booting from your BIOS/UEFI settings, press Del or F2 while your computer boots, and choose one or more of the following options, as appropriate:

- Enable onboard NIC
- Enable LAN boot ROM
- Boot sequence: network first

LTSP supports both BIOS and UEFI network booting, but not IPv6 network booting yet.

## iPXE

[iPXE](https://ipxe.org) contains various network drivers and is able to netboot most clients. It can be installed by various forms:

- [win32-loader.exe](http://ftp.debian.org/debian/tools/win32-loader/stable/win32-loader.exe): if your clients have a local disk with Microsoft Windows installed in BIOS mode, win32-loader adds a "Boot from network" option to the Windows boot manager.
- [grub-ipxe](https://packages.ubuntu.com/grub-ipxe): if your clients have Ubuntu etc, running `apt install grub-ipxe` adds a "Boot from network" option to the Grub boot manager.
- [ipxe.lkrn](https://boot.ipxe.org/ipxe.lkrn): can be used in other distributions that don't have the grub-ipxe package.
- [ipxe.iso](https://boot.ipxe.org/ipxe.iso): iPXE in CD ROM format.
- [ipxe.usb](https://boot.ipxe.org/ipxe.usb): iPXE in USB format. Just `dd` it to a USB stick.
- [ipxe.dsk](https://boot.ipxe.org/ipxe.dsk): iPXE in floppy disk format.
- [ipxe.efi](https://boot.ipxe.org/ipxe.efi): can be copied in a local EFI partition if the clients are UEFI and for some reason the internal PXE stack isn't appropriate.
