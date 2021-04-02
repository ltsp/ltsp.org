---
parent: Advanced topics
---

# ISC DHCP server

[Dnsmasq](https://ltsp.org/man/ltsp-dnsmasq/) is the recommended default for LTSP, as it's the only one that supports the proxyDHCP protocol.
In some cases though, sysadmins might need isc-dhcp-server. The following template dhcpd.conf works out of the box for dual NIC LTSP setups:

```shell
# This file is part of LTSP, https://ltsp.org
# Copyright 2019 the LTSP team, see AUTHORS
# SPDX-License-Identifier: GPL-3.0-or-later

# Configure isc-dhcp-server for LTSP
# Documentation=man:ltsp(8)

authoritative;
# option domain-name "example.org";
option domain-name-servers 192.168.67.1, 8.8.8.8, 208.67.222.222;
option space ipxe;
option ipxe-encap-opts code 175 = encapsulate ipxe;
option ipxe.menu code 39 = unsigned integer 8;
option ipxe.no-pxedhcp code 176 = unsigned integer 8;
option arch code 93 = unsigned integer 16;

# This is the LTSP subnet declaration
subnet 192.168.67.0 netmask 255.255.255.0 {
  range 192.168.67.20 192.168.67.250;
  option ipxe.no-pxedhcp 1;
  option routers 192.168.67.1;
  # On single-NIC setups, usually routers != next-server (=TFTP server)
  # option next-server 192.168.67.1
  if exists ipxe.menu {
    filename "ltsp/ltsp.ipxe";
  } elsif option arch = 00:00 {
    filename "ltsp/undionly.kpxe";
  } elsif option arch = 00:07 {
    filename "ltsp/snponly.efi";
  } elsif option arch = 00:09 {
    filename "ltsp/snponly.efi";
  } else {
    filename "ltsp/unmatched-client";
  }
}

# Example for a host with static IP address and default iPXE menu entry
# host pc01 {
#   hardware ethernet 3c:07:71:a2:02:e3;
#   fixed-address 192.168.67.7;
#   option host-name "pc01";
#   option root-path "ipxe-menu-item";
# }
```

Put it in /etc/dhcpd/dhcpd.conf. If you have Ubuntu and LTSP5, delete /etc/ltsp/dhcpd.conf as it interferes. Then if you also have dnsmasq installed, disable its DHCP service. Finally, restart isc-dhcp-server:

```shell
ltsp dnsmasq --proxy-dhcp=0 --real-dhcp=0
systemctl restart isc-dhcp-server
```

If isc-dhcp-server runs somewhere else and not on the LTSP server, you'll probably need to modify the subnet range, the routers, and uncomment next-server and set it to the LTSP server IP. **Note** that in this case, it's easier to configure your external DHCP server **not** to offer a boot filename, and just run `ltsp dnsmasq` to use its default proxyDHCP mode.
