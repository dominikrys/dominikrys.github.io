---
title: "Executing Stream Cipher Attacks on IP Packets in C++"
date: 2021-07-07T10:36:55+01:00
draft: true
toc: true
images:
tags:
  - c++
  - srslte
  - security
  - networking
---

For part of my bachelor's dissertation, I implemented and executed a bit-flipping attack on encrypted IP packets in LTE networks. The attack was first documented by David Rupprecht et al. in their academic paper ["Breaking LTE on Layer Two"](https://alter-attack.net/).

The attack is possible due to a specification flaw in LTE standards, where IP packets **not integrity protected**. Therefore, a man-in-the-middle (MITM) attacker can modify the packets and the receiver will decrypt them successfully, since it can't verify the authenticity of the data. The specifics on how this is possible are explained later in this post.

I learned a lot while implementing this attack which I thought would be worth documenting and sharing. Some of this post will refer to LTE networks specifically, but I will try to keep much of it general. This post will encompass how to do bitmasking comfortably in C++, how to find packet offsets using appropriate tools, and how to compensate for any checksum errors in IP packets.

## Stream Cipher Attack Explanation

In most LTE networks, IP packets are encrypted with a **stream cipher** (AES-CTR), where the encryption algorithm generates streams of bytes (called **keystreams**) which are XORed with the message plaintext in order to obtain the ciphertext. The receiver can then generate the same keystream and XOR it with the encrypted message to obtain the plaintext.

{{< image src="img/stream-cipher-diagram.png" alt="Stream Cipher Diagram" position="center" style="border-radius: 0.5em;" >}}

As explained at the start of the post, a MITM attacker attacker can successfully modify packets in LTE networks and the receiver will be able to decrypt them. This is known as a [malleable cipher](https://en.wikipedia.org/wiki/Malleability_(cryptography)). This property can be used by an attacker to modify the ciphertext in such a way that it decrypts into *any* chosen plaintext, if the original plaintext is known. I highly recommend reading a short description of how the attack works on [Wikipedia](https://en.wikipedia.org/wiki/Stream_cipher_attacks#Bit-flipping_attack).

As an example in the context of LTE networks, the network provides the IP of the DNS server that connected devices should use for DNS resolution. In effect, the plaintext of the destination IP of DNS requests is known. An attacker can restrict the mask it applies to the ciphertext to only cover the destination IP field, since the offset of it is known. The attack can therefore change the destination IP an arbitrary address (within limits) and hijack the request.

{{< image src="img/attack-diagram.png" alt="Attack Diagram" position="center" style="border-radius: 0.5em;" >}}

## Implementing the Bit-Flipping Stream Cipher Attack in C++

Now with the basics out of the way, I will explain how to implement a bit-flipping stream cipher attack where the plaintext is known in C++.

### Obtaining Field Offsets

The encrypted packets can be encapsulated in various protocols, so the offset at which to apply the bitmask will differ depending on the context. With more common protocols you can easily find this information on the internet. In other cases, Wireshark and some testing may be needed.

In my case, I was working with IPv4 packets encapsulated in the LTE PDCP protocol. Obtaining the offset of the destination IP in the IPv4 packet was trivial, but I found [Salim Gasmi's Hex Packet Decoder](https://hpd.gasmi.net/) to be an excellent tool to help with this. The PDCP protocol only adds a 2-byte header to the front of IP packets, so the offset found before had have 2 added to it for it to work in the context of PDCP packets.

To additionally verify if my assumptions were correct, I checked example packets in Wireshark. This would also need to be done when working with more exotic protocols. To obtain sample packets, I captured packets in a test setup with known keys such that the packets can be decrypted. Since we're working with a stream cipher, the offsets will be the same whether encryption is enabled or not. In the Wireshark trace, I was able to verify that my prior thinking was correct, and that I chose the appropriate offset.

{{< image src="img/pdcp-trace.png" alt="Wireshark PDCP Trace" position="center" style="border-radius: 0.5em;" >}}

TODO: add caption or describe image

## TODO

- how to bitmask and structure the data in C++
  - use valarray and XOR? straight up just loop then with the offset applied
  - how to get offsets - wireshark, that packet website
- how to compensate for the checksum being wrong - usually possible

- add photo to top of page
- add photos to more parts of the blog post
- grammarly check
