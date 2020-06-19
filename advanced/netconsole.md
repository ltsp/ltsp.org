---
parent: Advanced topics
---

# Netconsole

Linux logs important messages, like out-of-memory conditions or module problems or kernel crashes, to the kernel ring buffer, which we can normally inspect with the `dmesg` command. They also show up on the screen if Linux is running in text mode, but not if it's running in graphics mode.

This means that if an LTSP client crashes, we frequently can't even see why it crashed. To remedy this, one can enable the [netconsole](https://wiki.archlinux.org/index.php/Netconsole) module, and forward the client kernel messages to the server.

To enable netconsole:
* First run `ip l` on a client to see its Ethernet adapter name, for example `enp0s3`.
* Then add this parameter to the client kernel cmdline: `netconsole=@${ip}/enp0s3,@${srv}/`<br>
If you're not using iPXE, manually replace `${ip}` and `${srv}` with the IPs of the client and the server.
* You may also add `loglevel=5` to see more messages; the default is 4, and the valid values are 0-8.
* If you use loglevel, you may also need `POST_INIT_NETCONSOLE="rm -f /etc/sysctl.d/10-console-messages.conf"` in ltsp.conf, otherwise that file resets the `/proc/sys/kernel/printk` contents to `4 4 1 7`.

When you want to inspect the client messages, run one of the following commands on the server:
* `socat UDP-LISTEN:6666,fork -` (safer)
* `nc -l -u 6666`

Note: this was tested on initramfs-tools (Debian-based), but not on dracut (Fedora-based).
