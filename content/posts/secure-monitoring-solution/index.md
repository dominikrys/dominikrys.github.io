---
title: "Setting up a TLS-Secured Monitoring Solution in Docker using InfluxDB, Grafana and Traefik"
date: 2020-12-1T12:51:48+01:00
draft: true # TODO: change this
toc: true
comments: true
tags:
  - docker, influxdb, grafana, traefik, monitoring, devops, security
---

![Architecture Diagram](img/diagram.png)

## Motivation

During my last internship, I've been tasked with designing and deploying infrastructure for a cluster of machines that was used for performance testing. I wrote a blog-post detailing high-level choices about it which you can check out [here]({{< ref "/content/posts/monitoring-corda-nodes/index.md" >}} "Monitoring Corda Nodes"). That post also goes into justifications as to why I chose to deploy everything in Docker, and why I chose [Grafana](https://grafana.com/) as the front-end, and [InfluxDB](https://www.influxdata.com/products/influxdb/) as the time-series database, which I will describe in this post.

I found it relatively straightforward to write and deploy a Docker compose application with just Grafana and InfluxDB as there are many ready-made `docker-compose.yml` files that can be found online, as well as various tutorials and blog posts going in depth into the details. The main difficulty was in getting the application secured by issuing and renewing TLS certificates. The first port of call was trying to manually issue and set TLS certificates as described e.g. in the [InfluxDB documentation](https://docs.influxdata.com/influxdb/v1.7/administration/https_setup/), but this wouldn't be maintainable in the long run.

This is where [traefik](https://traefik.io/traefik/) came in - it's an edge router which works as a reverse proxy into the Docker compose application, and is capable of auto-issuance and auto-renewal of TLS certificates from [Let's Encrypt](https://letsencrypt.org/). I'll describe how to set it up later in this post. Traefik can also be used with other Docker containers, if you for example use [Prometheus](https://prometheus.io/) instead as your TSDB.

Apart from that, I'll use this post as an opportunity to describe various other things I found when working on this project that may prove useful to someone.

For the finished all-in-one deployment of Grafana, InfluxDB and Traefik that this post will build up to, check this GitHub repo: [Secure Monitoring Solution in Docker](https://github.com/dominikrys/docker-influxdb-grafana-traefik).

## Setting up Grafana and InfluxDB

Include simple docker compose

Hold passwords in Ansible or docker secrets

Data can now be sent using e.g. Telegraf

## Securing containers using Traefik

Initially found thanks to this: https://www.grzegorowski.com/secure-docker-grafana-container-with-ssl-through-traefik-proxy

Show simplified docker-compose with traefik

Describe how everything in Traefik works

- HTTP to HTTPS redirection

- CA Servers + rate limits

> There is a limit of 5 certificates per week from Let's Encrypt's production server as stated [here](https://letsencrypt.org/docs/rate-limits/). For more info on the Let's Encrypt staging environment and Traefik, check the note under this [Traefik docs page](https://docs.traefik.io/v2.0/user-guides/docker-compose/acme-tls/#setup).

- Email

### Traefik Tips

Stuff can be sent to InfluxDB now, but watch out for stuff that breaks on TLS certs. I use traefik.

If stuff complains about TLS, disable it. Have separate config for local deployments. traefik.http.routers.influxdb-ssl.tls label to false for the InfluxDB container inside docker-compose.yml.

## General info

InfluxDB will run shell scripts in docker-entrypoint-initdb.d on startup. Don't include .iql files there and instead only sh

### Grafana

- Grafana automatically sets up data sources specified under `grafana/provisioning/datasources`. They can be overridden when Grafana is restarted.

  - Tried to make it work with automatically setting up for InfluxDB flux, but not officially supported

  - Other stuff can be provisioned.

- If you ever receive a `Network Error: Unauthorized (401)` error in Grafana, restart your web browser. If that doesn't work then clear your browser cache.

### InfluxDB

- Watch out when using Flux as it can eat up all your memory. Use Chronograf is you want a nice frontend for working with it.

## Conclusion

Full Github repo on the top
