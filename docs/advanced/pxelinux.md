# PXELinux

[iPXE](https://ltsp.org/man/ltsp-ipxe/) is the recommended default for LTSP, as it has great support for UEFI and HTTP, it provides a scripting language with variables, conditional instructions, dynamic menus etc. It even includes drivers for many popular network cards, and it's required for netbooting when the NIC isn't onboard and there's no BIOS "driver" for it.

For onboard NICs, iPXE tries to implement the aforementioned functionality using /srv/tftp/ltsp/undionly.kpxe. This is a wrapper driver that uses the underlying BIOS PXE stack, but in certain cases the PXE stack may be buggy and cause iPXE to either fail with e.g. "Network unreachable" or even to completely hang.

One workaround is to execute the following command on the LTSP server in order to replace undionly.kpxe with ipxe.pxe:

```shell
sudo wget https://boot.ipxe.org/ipxe.pxe -O /srv/tftp/ltsp/undionly.kpxe
```

While undionly.kpxe only contains the wrapper driver, ipxe.pxe contains all the iPXE drivers. If a native driver exists, it'll be used and it will probably work fine.

Thus, the rest of this page refers to the following scenario:

- The NIC is onboard (it has a PXE stack)
- You're using BIOS, not UEFI
- Neither undionly.kpxe nor ipxe.pxe worked

If these conditions are met, [PXELinux](https://wiki.syslinux.org/wiki/index.php?title=PXELINUX) might help, as it's simpler and doesn't exploit all the functionality of the (possibly buggy) PXE stack. To install PXELinux on your LTSP server, run:

```shell
sudo -i
cd /srv/tftp/ltsp
apt install pxelinux syslinux
ln -s /usr/lib/PXELINUX/pxelinux.0 pxelinux.0
ln -s /usr/lib/syslinux/modules/bios isolinux
mkdir -p pxelinux.cfg
wget https://ltsp.org/advanced/pxelinux.txt -O pxelinux.cfg/default
```

The next step is to configure dnsmasq to point one or more clients to use PXELinux instead of iPXE. Create `/etc/dnsmasq.d/local.conf` with the following content:

```text
# Documentation=https://ltsp.org/advanced/pxelinux/
dhcp-mac=set:pxelinux,52:54:61:67:00:01
pxe-service=tag:pxelinux,X86PC,"pxelinux.0",ltsp/pxelinux.0
dhcp-boot=tag:pxelinux,ltsp/pxelinux.0
```

In the `dhcp-mac=` line, it's possible to use wildcards, e.g. `dhcp-mac=set:pxelinux,08:00:27:*:*:*` would match all VirtualBox clients. Run the following command to restart dnsmasq:

```shell
sudo systemctl restart dnsmasq
```

Then restart the problematic LTSP clients. If they boot successfully with PXELinux, you may optionally fine-tune its menu by editing its configuration file, `/srv/tftp/ltsp/pxelinux.cfg/default`.
