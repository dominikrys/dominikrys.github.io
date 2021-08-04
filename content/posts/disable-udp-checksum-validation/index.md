---
title: "How to Disable UDP Checksum Validation in Linux"
date: 2021-05-20T12:37:22+01:00
cover:
    image: "img/cover.jpg"
tags:
  - security
  - devops
  - linux
  - networking
---

I recently needed to disable the validation of UDP checksums of incoming packets on a Linux machine for a security project. To my surprise, there weren't any satisfactory solutions that I could easily find online related to this. The top results also suggested disabling checksum offloading, which doesn't disable checksum checking. In the end, I managed to figure this problem out and found that it's possible without recompiling the kernel. In this short post, I'll describe how to set up a Linux machine to ignore UDP checksums in received packets. The mentioned steps may also be adapted to allow for disabling TCP checksum checking.

## Check if your machine can receive packets with broken UDP checksums

Firstly, we need to check if your machine can already accept packets with invalid UDP checksums. Testing this is easy - send packets with broken UDP checksums from one machine (machine 1) to the machine that you want to disable validation on (machine 2), and check the traffic using `tcpdump`. I'll outline how I've done this below.

1. Run `tcpdump` on machine 1, listening to internet traffic at port 53:

    ```bash
    sudo tcpdump -i <NETWORK INTERFACE> dst port 53 -vv
    ```

    To get the network interface names, you can run `ip link show`.

2. Disable transmit checksum offloading on machine 1. This is so that any invalid checksums won't be corrected by the hardware. In some cases, it may not be possible to disable this, so another machine may need to be used. To disable transmit checksum offloading on Linux, run:
  
    ```bash
    sudo ethtool --offload <NETWORK INTERFACE> tx off
    ```

3. Download and run [Scapy](https://github.com/secdev/scapy) on machine 2.

4. Craft a DNS packet with a broken UDP checksum using Scapy on machine 2:

    ```bash
    bad_packet = IP(dst='<MACHINE 1 IP>') / UDP() / DNS(rd=1, qd=DNSQR(qname="www.example.com"))
    ```

    Make sure to replace `<MACHINE 1 IP>` with the IP of machine 1.

5. Send the packet with a broken checksum from machine 2 to machine 1:

    ```bash
    send(bad_packet)
    ```

6. Check the `tcpdump` logs on machine 1. If the packet is received stating `bad udp cksum` in the logs, the machine can receive packets with broken UDP checksums. We can then continue with adding rules to ignore the checksums.

### What if my machine doesn't receive packets with invalid UDP checksums?

A router between your machines could discard the packet due to an incorrect UDP checksum. Such an issue can be hard to diagnose, so it may be circumvented by sending packets from another machine.

If the packet is *still* not received, the kernel may be rejecting packets with invalid UDP checksums. In such case, the [`udp_recvmsg()`](https://leapster.org/linux/kernel/udp/#udp_recvmsg) function in the kernel would need to be modified to not return errors when the checksum validation fails. The kernel would then need to be recompiled - this can differ slightly between Linux distros, but many include useful documentation on how to achieve this (such as [this](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel) for Ubuntu).

Note that changes to the kernel were not needed on the three machines that I have tested this on (Ubuntu 18.04 in Microsoft Azure, Ubuntu 20.10 in DigitalOcean, and Arch Linux with kernel version 5.11.11) but your mileage may vary.

## Ignoring UDP checksums with nftables

So far, we've confirmed that packets with broken UDP checksums can be received by our machine. However, these packets won't get accepted by any target applications due to the invalid checksum. We can fix this using `nftables`.

We can configure `nftables` rules that set the UDP checksum of received packets to 0 before they're passed to any applications. Packets with UDP checksums of 0 will not have their checksums validated, effectively disabling UDP checksum validation.

To set this up, first install `nftables` with your favourite package manager. Next, add the following `nftables` rule:

```bash
sudo nft add table input_table
sudo nft 'add chain input_table input {type filter hook input priority -300;}'
sudo nft 'add rule input_table input ip protocol udp udp checksum set 0'
```

This rule will set the UDP checksum of every received IP UDP packet to 0. Your machine will now ignore UDP checksums of received packets! Feel free to test it using Scapy.

To make the rule persistent across reboots, I'd recommend reading through  [this short guide to `nftables`](https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes).

## Ignoring UDP checksums using socket options

If you have the source code of the application that you want to send the packets with broken UDP checksums to, it may be possible by using socket options. To do so, the `SO_NO_CHECK` option would need to be declared with the UDP socket file descriptor, as described [here](https://linux-tips.com/t/how-to-disable-udp-checksum-control-in-kernel/362).
