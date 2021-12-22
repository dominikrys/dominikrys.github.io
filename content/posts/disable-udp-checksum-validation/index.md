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

I recently needed to disable the validation of UDP checksums of incoming packets on a Linux machine for a security project. To my surprise, there weren't any satisfactory solutions that I could easily find online related to this. The top Google results suggest [disabling checksum offloading](https://www.linuxquestions.org/questions/linux-networking-3/help-needed-disabling-tcp-udp-checksum-offloading-in-debian-880233/), which doesn't disable checksum validation. Another result mentions [a solution from within application source code](https://linux-tips.com/t/how-to-disable-udp-checksum-control-in-kernel/362), which you may not have access to or be able to modify.

In the end, I managed to figure this problem out and found that it's usually possible without recompiling the kernel.

In this post, I'll describe how to set up a Linux machine to ignore UDP checksums in received packets. The mentioned steps may also be adapted to allow for disabling TCP checksum checking.

## Check If Your Machine Can Receive Packets with Broken UDP Checksums

Firstly, we need to check if your machine can already accept packets with invalid UDP checksums. This is necessary as your machine might already be able to receive them, but applications that are then passed the packets could be discarding them. Verifying this is also necessary to check if your network is capable of receiving packets with broken UDP checksums; there could be firewalls in place that verify packets before they reach your machine, in which case those will need to be reconfigured first.

Testing if your machine can already receive packets with broken checksums is straightforward - send packets with broken UDP checksums from one machine (source machine) to the machine that you want to disable UDP checksum validation on (destination machine), and check the traffic using `tcpdump`. I'll outline how I've done this below.

1. Run `tcpdump` on the destination machine, listening to internet traffic at the port that you expect to receive packets with broken UDP checksums on:

    ```bash
    sudo tcpdump -i <NETWORK INTERFACE> dst port <PORT> -vv
    ```

    To get the network interface names, you can run `ip link show`.

2. Disable transmit checksum offloading on the source machine. This is so that any packets with invalid checksums won't have their checksums corrected by hardware. In some cases, it may not be possible to disable this, so another machine may need to be used to send packets. To disable transmit checksum offloading on Linux, run:
  
    ```bash
    sudo ethtool --offload <NETWORK INTERFACE> tx off
    ```

3. Download and run [Scapy](https://github.com/secdev/scapy) on the source machine.

4. Craft a packet of the with a broken UDP checksum using Scapy on the source machine. This is an example for how to do this with DNS packets:

    ```bash
    bad_packet = IP(dst='<destination machine IP>') / UDP() / DNS(rd=1, qd=DNSQR(qname="www.example.com"))
    ```

5. Send the packet with a broken checksum from the source to the destination machine:

    ```bash
    send(bad_packet)
    ```

6. Check the `tcpdump` logs on the destination machine. If the packet is received stating `bad udp cksum` in the logs, the machine can receive packets with broken UDP checksums. We can then continue with adding `nftables` rules to ignore the checksums.

### What If My Machine Doesn’t Receive Packets with Invalid UDP Checksums?

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

This rule will set the UDP checksum of every received IP UDP packet to 0, which applications won't validate.

Your machine will now ignore UDP checksums of received packets! Feel free to test this using Scapy.

To make the rule persistent across reboots, I'd recommend following the advice in [this short guide to `nftables`](https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes).

## Ignoring UDP Checksums Using Socket Options

If you have the source code of the application that you want to send the packets with broken UDP checksums to, it may be possible by using socket options. To do so, the `SO_NO_CHECK` option would need to be declared with the UDP socket file descriptor, as described [here](https://linux-tips.com/t/how-to-disable-udp-checksum-control-in-kernel/362).
