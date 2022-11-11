---
title: "Configuring Squid as a Transparent Proxy"
date: 2021-04-10T10:08:45+01:00
cover:
    image: "img/squid-logo.png"
    alt: "Squid Logo"
tags:
  - Security
  - iptables
---

I've recently set up [Squid](http://www.squid-cache.org/) as a transparent proxy for a security project. What should have been relatively straightforward had me browsing through prehistoric tutorials that don't quite work any more. In the end, I managed to get a minimal transparent proxy configuration on a modern version of Linux hosted in the cloud.

With the hopes of saving someone some time that may be embarking on a similar journey, I thought I'd write this post. We discuss HTTP transparent proxying at the start, but provide resources for allowing support for HTTPS.

The following instructions have been tested on Ubuntu 18.04 deployed in Azure, and Ubuntu 20.04 on DigitalOcean.

## Installing Squid

This part is straightforward, so just follow the normal install procedure for your operating system/package manager. I used Ubuntu, so installing Squid was as easy as `sudo apt install squid`.

Before we continue, it's worth checking if Squid is able to run at this point (which may not be the case if something is using Squid's default port, for example). It should be running after installation, which you can check with `systemctl status squid`. If squid is not running, you can attempt to fix its configuration in the next step.

## Configuring Squid

### Configuration file

Now the most important part - the configuration. The config is stored under `/etc/squid/squid.conf`, but before we make any changes I like to make a copy of the original:

```bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
```

Next, edit the configuration file with your favourite text editor:

```bash
sudo vim /etc/squid/squid.conf
```

And enter this minimal configuration:

```plaintext
http_access allow all

http_port 3128 intercept
```

The `http_access` parameter should ideally be narrowed down as described in the [Squid documentation](http://www.squid-cache.org/Doc/config/http_access/), but to eliminate potential errors, we will permit anything to access the proxy at this point.

The `http_port` states which port Squid will listen at, for which we keep the default `3128`. We will redirect traffic to this port using `iptables` soon. `intercept` is needed to make Squid act as a transparent proxy.

**Nothing else** is necessary for a working configuration as of the time of writing this post, unlike what some other tutorials may lead you to believe. Note that in its current state, there will be a warning printed in the Squid logs whenever it's started, stemming from the fact that a non-transparent port is not open. If you'd like to silence that, you can have Squid listen at a vacant port by adding e.g. `http_port 3129` to the configuration.

Finally, we can restart Squid:

```bash
sudo systemctl restart squid
```

This should be it for the Squid configuration! Make sure to check if it's working, as described earlier in the post. If it's not, good places to start are the `journalctl` entries for squid, and the access and log files by default located at `/var/log/squid/access.log` and `/var/log/squid/cache.log`, respectively.

### Enabling IP forwarding

Since we're configuring a transparent proxy, we need to configure IP forwarding on the system:

```bash
sudo sysctl net.ipv4.ip_forward=1
```

To make this configuration persistent, modify `/etc/sysctl.conf` and uncomment the line:

```plaintext
#net.ipv4.ip_forward=1
```

### iptables Rules

To get the kernel to forward packets received at port 80 to Squid, we need the following `iptables` rule:

```bash
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3128
```

Make sure to modify the above rule, or add additional ones if you have other interfaces apart from `eth0` that you'd like to forward traffic from. Those can be found using e.g. `ip link show` or `ifconfig`. This rule makes it so that only external traffic will be send to Squid, and all traffic originating at the machine will reach its destination and not cause a cycle.

If at any point you make a mistake with your configuration, you can flush all existing `iptables` NAT rules:

```bash
sudo iptables -t nat -F
```

Or list any existing rules using:

```bash
sudo iptables -t nat -L
```

## Closing Notes - HTTPS Support, Gateway Setup, Spoofed Requests

You should now have a minimal Squid transparent proxy running. Make sure to configure the machine as the default gateway for whichever machines you'd like to transparently proxy data for.

To enable transparent proxying of HTTPS traffic, I recommend [suntong's guide](https://dev.to/suntong/squid-proxy-and-ssl-interception-1oa4).

Note that Squid is unable to resolve the original destination of packets that have had their destination IP spoofed ([source](http://squid-web-proxy-cache.1019090.n4.nabble.com/TProxy-and-client-dst-passthru-td4670189.html)). To resolve those properly, I've had luck using [Privoxy](https://www.privoxy.org/) in [intercepting mode](https://www.privoxy.org/faq/configuration.html#INTERCEPTING) as I describe in [this post]({{< ref "../transparently-proxy-spoofed-ip/index.md" >}} "Transparently Proxy IP Packets With Spoofed Destinations").

Thanks for reading, and I hope that this post helped anyone struggling with Squid!
