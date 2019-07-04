---
parent: Documentation
nav_order: 1
---

# Preparation

Before installing LTSP, make sure that it fits your needs and that your hardware is appropriate.

## When to use

The main reason to use LTSP is if you want to maintain a single installation, instead of many. It saves administration time.

The older LTSP5 targetted thin clients with reduced hardware specifications; this is no longer the case. The LTSP clients should be able to run the distribution with their own CPU/RAM; except with LTSP they'll be using a network disk instead of a local disk, so they can be diskless.

## Network

- The server ⟺ switch connection should be gigabit; i.e. gigabit server NIC, switch port and 5e+ cabling.
- The clients ⟺ switch connection may be 100 Mbps.
- It's best if the LTSP clients are connected to the same switch as the server.

As network performance is very important for LTSP, after it's up and running do a LAN benchmark with epoptes, to make sure the server can send and receive data with at least 800 Mbps bandwidth.

## Server

Any recent PC will do with e.g. 4 GB RAM and 3000 cpubenchmark.net score. An SSD disk for both rootfs and home will probably make client network disk access a bit faster.

## Clients

Consult your distribution for client specifications. 1 GB RAM with 500 cpubenchmark.net score could be the minimal specs, and 2 GB RAM / 2000+ score the recommended.
