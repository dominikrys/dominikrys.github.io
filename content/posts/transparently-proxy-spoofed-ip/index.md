---
title: "How to Transparently Proxy IP Packets With Spoofed Destinations"
date: 2021-04-17T10:44:53+01:00
cover:
  image: "img/diagram.png"
  alt: "Proxy Diagram"
tags:
  - security
  - networking
  - iptables
  - linux
---

I've recently worked on a security project which required me to transparently proxy IP packets that have had their destination IPs spoofed. By this, I mean that the destination IP in an IP packet is **not** the IP of the destination which a DNS request would correctly resolve. For example, this could be due to a DNS query being spoofed and sending an IP address of another destination in reply. The diagram above shows what we want to achieve.

In this post, I will explain how it's possible to proxy such HTTP traffic by redirecting it to the correct destination.

## Why can't spoofed DNS packets be proxied using an ordinary transparent proxy?

When an IP packet with a spoofed destination IP reaches its destination server, the server will handle it like any other IP packet that has been destined for it. Ordinary transparent proxying tools such as [Squid](http://www.squid-cache.org/) are usually configured as internet gateways, so they are not the final destination of the IP packets that pass through them. Since the final destination IP of each packet is known in such setups, these tools can easily send packets to their destination. If the destination IP **is** the proxy, as it would be in the case of spoofed destination IPs, the transparent proxy would need to additionally resolve the original destination IP. Most such tools don't have support for this.

## How to reclaim the original destination?

To reclaim the original destination, the `Host` header can be used which is [required by HTTP/1.1](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Host). The `Host` header contains the domain name that the client wants to access. In the case of spoofed destination IPs, this header will be intact and pointing to the un-spoofed destination.

To reclaim the original destination, proxy software is needed that can do a DNS lookup on the `Host` header and send traffic to the destination resulting from the lookup. Sadly, in this case, the most popular transparent proxy software won't work. I tried extensively to make this work with Squid, but there are some reasons why it's not possible (more [here](http://squid-web-proxy-cache.1019090.n4.nabble.com/TProxy-and-client-dst-passthru-td4670189.html) and [here](http://squid-web-proxy-cache.1019090.n4.nabble.com/Force-squid-use-dns-query-result-as-the-destination-server-in-squid-tproxy-td4664036.html)).

It's also worth mentioning that since this proxy will change the destination IP of the packet, it stops being "transparent", and is now an "intercepting" proxy. I thought that this term is reserved for slightly more involved proxies such as [Burp](https://portswigger.net/burp/documentation/desktop/tools/proxy/getting-started), but it also applies in this case.

To resolve packets according to their `Host` header, I used [**Privoxy**](https://www.privoxy.org/) in [intercepting mode](https://www.privoxy.org/faq/configuration.html#INTERCEPTING), which I will explain how to configure.

## How to configure Privoxy to resolve spoofed IP packets?

Luckily the configuration for Privoxy is very simple. First, install it using your operating system's package manager. Next, modify its configuration file under `etc/privoxy/config` with the following details, where `INTERFACE_IP` is the IP of the interface that you want Privoxy to listen at:

```plaintext
listen-address INTERFACE_IP:3128
accept-intercepted-requests 1
debug 1
```

Note that `debug 1` is not strictly needed, but it will allow us to see if requests are coming through to the server. `accept-intercepted-requests 1` is the important part, which enabled the "intercepting" mode of Privoxy.

Next, restart privoxy:

```bash
sudo systemctl restart privoxy
```

Finally, add an `iptables` rule to redirect traffic from the HTTP port to the port that Privoxy is listening at:

```bash
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8118
```

You can modify the above rule or add additional ones if you have other interfaces apart from `eth0` that you'd like to forward traffic from.

Now you can send some spoofed requests to the server and check if you can see them in the logs:

```bash
$ sudo tail -f /var/log/privoxy/logfile

2021-04-15 15:06:24.434 7f39feffd700 Request: scratchpads.org/
2021-04-15 15:06:24.789 7f39feffd700 Request: scratchpads.org/css/main.css
2021-04-15 15:06:24.795 7f39dffff700 Request: scratchpads.org/css/index.css
2021-04-15 15:06:24.931 7f39ff7fe700 Request: work.a-poster.info:25000/
2021-04-15 15:06:26.503 7f39dffff700 Request: scratchpads.org/assets/why/accordion.js
2021-04-15 15:06:26.554 7f39feffd700 Request: scratchpads.org/assets/index.js
```

## HTTPS support?

The method described in this post won't work for HTTPS requests, since the HTTP header will be encrypted and the `Host` header won't be able to be read. As far as I know there are no tools available that would be able to do this. In theory, it's possible to make this work with HTTPS in a transparent manner, but with substantial engineering effort.

I'm envisioning a solution where the spoofing DNS server redirects each request to a different machine, where each machine knows about the original destination of the packets. The machines can then redirect packets to their correct destinations. The contents will still be encrypted, so it's questionable whether something like this would be worth doing at all.
