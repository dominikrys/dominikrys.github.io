---
title: "Setting up a TLS-Secured Monitoring Solution in Docker using InfluxDB, Grafana and Traefik"
date: 2020-12-01T12:51:48+01:00
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

Setting up Grafana and InfluxDB on Docker is pretty straightforward. Here's a `docker-compose.yml` that will do just that:

```yml
version: "3.8"

services:
    influxdb:
        container_name: influxdb
        image: influxdb:1.8.3-alpine
        ports:
            - 8086:8086
        volumes:
            - influxdb-data:/var/lib/influxdb
        environment:
            INFLUXDB_DB: example_db # This database will be created on initialisation

            INFLUXDB_ADMIN_USER: admin
            INFLUXDB_ADMIN_PASSWORD: influxdb-admin
        networks:
            - monitoring

    grafana:
        container_name: grafana
        image: grafana/grafana:7.3.4
        ports:
            - 3000:3000
        volumes:
          - grafana-data:/var/lib/grafana
        environment:
            GF_SECURITY_ADMIN_USER: grafana
            GF_SECURITY_ADMIN_PASSWORD: grafana-admin
        networks:
            - monitoring
        depends_on:
            - influxdb

networks:
    monitoring:
        driver: bridge

volumes:
    influxdb-data:
        external: false

    grafana-data:
        external: false
```

This simple Docker compose application creates Grafana and InfluxDB containers, creates persistent volumes for them so data will be saved if they're restarted, and sets up a networking bridge so the containers can communicate between each other (in favour of the legacy [`links`](https://docs.docker.com/network/links/) command that some old setups use).

To start up the containers, run `docker-compose up`.

Grafana can then be accessed at port `3000` and InfluxDB at port `8086`. You can go ahead and send some data to InfluxDB (e.g. with [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/)) to make sure it works. InfluxDB will need to be set up as a data source manually in Grafana, but I'll describe how this can be automated later.

The admin account details are provided in the `docker-compose.yml` so feel free to change them to something secure. For ideas on how to store them securely, check out [Docker secrets](https://docs.docker.com/engine/swarm/secrets/) or [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

This kind of configuration is the foundation of your Grafana and InfluxDB monitoring setup. I'll discuss some further improvements that can be implemented to improve readability and maintainability of the application. For now, feel free to change any settings using the appropriate environment variables (I found it to work better than mounting a config file into the container).

## Securing containers using Traefik

Initially I found how to secure the described Docker compose deployment with Traefik from [Jan Grzegorowski's blog post](https://www.grzegorowski.com/secure-docker-grafana-container-with-ssl-through-traefik-proxy). I highly recommend reading his post if something is not clear here, albeit it's slightly outdated.

As described already, Traefik is a cloud-native edge router which will serve as a reverse proxy in our Docker compose application. It will automatically issue and renew TLS certificates, so the traffic to our Docker containers will be encrypted.

Adapting the above example `docker-compose.yml` to work with Traefik, we get:

```yml
version: "3.8"

services:
    influxdb:
        container_name: influxdb
        image: influxdb:1.8.3-alpine
        volumes:
            - influxdb-data:/var/lib/influxdb
        networks:
            - monitoring
        labels:
            - "traefik.http.routers.influxdb-ssl.entryPoints=influxdb-port"
            - "traefik.http.routers.influxdb-ssl.rule=host(`YOUR_DOMAIN`)"
            - "traefik.http.routers.influxdb-ssl.tls=true"
            - "traefik.http.routers.influxdb-ssl.tls.certResolver=lets-encrypt-ssl"
            - "traefik.http.routers.influxdb-ssl.service=influxdb-ssl"
            - "traefik.http.services.influxdb-ssl.loadBalancer.server.port=8086"

    grafana:
        container_name: grafana
        image: grafana/grafana:7.3.4
        volumes:
          - grafana-data:/var/lib/grafana
        networks:
            - monitoring
        depends_on:
            - influxdb
        labels:
            - "traefik.http.routers.grafana.entryPoints=port80"
            - "traefik.http.routers.grafana.rule=host(`YOUR_DOMAIN`)"
            - "traefik.http.routers.grafana.middlewares=grafana-redirect"
            - "traefik.http.middlewares.grafana-redirect.redirectScheme.scheme=https"
            - "traefik.http.middlewares.grafana-redirect.redirectScheme.permanent=true"

            - "traefik.http.routers.grafana-ssl.entryPoints=port443"
            - "traefik.http.routers.grafana-ssl.rule=host(`YOUR_DOMAIN`)"
            - "traefik.http.routers.grafana-ssl.tls=true"
            - "traefik.http.routers.grafana-ssl.tls.certResolver=lets-encrypt-ssl"
            - "traefik.http.routers.grafana-ssl.service=grafana-ssl"
            - "traefik.http.services.grafana-ssl.loadBalancer.server.port=3000"

    traefik:
        container_name: traefik
        image: traefik:v2.3.4
        volumes:
            - traefik-data:/letsencrypt
            - /var/run/docker.sock:/var/run/docker.sock
        networks:
            - monitoring
        ports:
            - "80:80"
            - "443:443"
            - "8086:8086"
        command:
            - "--providers.docker=true"

            - "--entryPoints.port443.address=:443"
            - "--entryPoints.port80.address=:80"
            - "--entryPoints.influxdb-port.address=:8086"

            - "--certificatesResolvers.lets-encrypt-ssl.acme.tlsChallenge=true"
            - "--certificatesResolvers.lets-encrypt-ssl.acme.storage=/letsencrypt/acme.json"
            - "--certificatesresolvers.lets-encrypt-ssl.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"
            - "--certificatesResolvers.lets-encrypt-ssl.acme.email=YOUR-EMAIL@website.com"

networks:
    monitoring:
        driver: bridge

volumes:
    influxdb-data:
        external: false

    grafana-data:
        external: false

    traefik-data:
        external: false
```

There's quite a lot going on here! I'll try to break it down bit by bit.

First, the ports for the Grafana and InfluxDB containers have been removed, as Traefik will now act as an entry point for them.

Next, we create some labels in the InfluxDB container for out Traefik configuration. Everything in Traefik for Docker can be configured using [labels](https://doc.traefik.io/traefik/providers/docker/).

```yml
- "traefik.http.routers.influxdb-ssl.entryPoints=influxdb-port"
```

This label sets the container's entrypoint and corresponds to the appropriate label in the Traefik container - here we called it `influxdb-port`, but any name can be chosen. Note that the fourth part of the label can have any arbitrary name (here I chose `influxdb-ssl`).

```yml
- "traefik.http.routers.influxdb-ssl.rule=host(`YOUR_DOMAIN`)"
```

The start of the TLS configuration - fill in your domain here which will be used for the TLS configuration.

```yml
- "traefik.http.routers.influxdb-ssl.tls=true"
```

Enable TLS for this container. Changing this to false can be useful when testing locally so TLS certificates can't be issues, and you want to send data to InfluxDB from applications that can't be set to ignore TLS certificates.

```yml
- "traefik.http.routers.influxdb-ssl.tls.certResolver=lets-encrypt-ssl"
```

The name of the certificate resolver - make sure it matches the name of the certificate resolver in the Traefik container

```yml
- "traefik.http.routers.influxdb-ssl.service=influxdb-ssl"
```

Set the Traefik service name to the name that the other labels have been given

```yml
- "traefik.http.services.influxdb-ssl.loadBalancer.server.port=8086"
```

Effectively sets the entrypoint to the underlying container. This is determined by the Docker image itself, so be sure to check which port to use for other containers.

The Grafana TLS configuration labels are largely the same, however there is an configuration for HTTP to HTTPS redirection:

```yml
- "traefik.http.routers.grafana.entryPoints=port80"
- "traefik.http.routers.grafana.rule=host(`YOUR_DOMAIN`)"
- "traefik.http.routers.grafana.middlewares=grafana-redirect"
- "traefik.http.middlewares.grafana-redirect.redirectScheme.scheme=https"
- "traefik.http.middlewares.grafana-redirect.redirectScheme.permanent=true"
```

Since we want Grafana to be what users will see when they access the domain, we handle the HTTPS to HTTP redirection elegantly using Traefik. I won't get too in depth into how this works as the principles are similar to the other Traefik labels.

Finally, we set up the actual Traefik container:

```yml
traefik:
    container_name: traefik
    image: traefik:v2.3.4
    volumes:
        - traefik-data:/letsencrypt
        - /var/run/docker.sock:/var/run/docker.sock
    networks:
        - monitoring
    ports:
        - "80:80"
        - "443:443"
        - "8086:8086"
```

First, we set up a persistent volume mounted (?)for the `/letencrypt` directory which will store our TLS certificates obtained from Let's Encrypt. This helps as then certificates don't have to be reissued on container restart.

Next, we need to mount the Docker socket into the container so that Traefik can get [Docker's dynamic configuration](https://docs.traefik.io/providers/docker/#docker-api-access).

Open the ports for all our containers, as all traffic will not go through Traefik,

```yml
command:
    - "--providers.docker=true"

    - "--entryPoints.port443.address=:443"
    - "--entryPoints.port80.address=:80"
    - "--entryPoints.influxdb-port.address=:8086"

    - "--certificatesResolvers.lets-encrypt-ssl.acme.tlsChallenge=true"
    - "--certificatesResolvers.lets-encrypt-ssl.acme.storage=/letsencrypt/acme.json"
    - "--certificatesresolvers.lets-encrypt-ssl.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"
    - "--certificatesResolvers.lets-encrypt-ssl.acme.email=YOUR-EMAIL@website.com"
```

We set up the `providers.docker` command to true since we're using docker, and give container entry point names that we wish to use, and bind them to ports

Finally we set up the certificate resolver that will renew and issue our TLS certificates. Note that the second part of these labels doesn't matter and can be set to anything.

The `caServer` label determines which server the certificates will be issues from - staging (`https://acme-staging-v02.api.letsencrypt.org/directory`) or production (`https://acme-v02.api.letsencrypt.org/directory`). There is a limit of 5 per week from [Let's Encrypt's production server](https://letsencrypt.org/docs/rate-limits/), so it may be a good idea to use the staging server for testing. For more info on the Let's Encrypt staging environment and Traefik, check the note under [this Traefik docs page](https://doc.traefik.io/traefik/v2.0/user-guides/docker-compose/acme-tls/#setup).

The email is necessary for Let's Encrypt to contact you about [expiring certificates and any issues related to your account](https://cert-manager.io/docs/configuration/acme/#creating-a-basic-acme-issuer).

This is enough to get your Docker containers secured and all traffic encrypted!

## Improvements

This is all you need to get your Docker containers set up with TLS certificates!

I'll describe some further improvements that can be made to the docker application if you're interested. Many of the improvements have been implemented in the GitHub repository that I've linked to at the top of this post.

- `volumes` configurations have been expanded to their verbose form, which greatly helps with understanding what kind of mount is used (especially if you're not familiar with Docker).

- An `.env` file can be used to store some common variables which are used throughout the `docker-compose.yml` and to avoid repetition.

- `restart: always` can be added to the Docker containers to restart the containers on boot.

- Grafana automatically sets up data sources specified under `grafana/provisioning/datasources`. They can be overridden when Grafana is restarted. Other aspects can also be provisioned, including plugins, dashboards and alert notification channels. For more info, see [Grafana provisoning](https://grafana.com/docs/grafana/latest/administration/provisioning/).

- InfluxDB will run shell scripts in the `docker-entrypoint-initdb.d` directory on startup. InfluxQL `.iql` files can also be included there, but I wouldn't recommend it as they're much less flexible than shell scripts and can lead to non-obvious issues.

TODO:
- go through todos
- re-read
