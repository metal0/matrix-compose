# matrix-compose

## What is it?

matrix-compose is a collection of scripts and config files intended to make setting up and configuring a small/personal [Matrix](https://matrix.org/) homeserver easier.


Included in the docker-compose services are, along with a working homeserver (Synapse) setup, various social media bridges (Discord, Facebook, Google Messages, Google Chat, Instagram, LinkedIn, Signal, Slack, Steam, Telegram, Twitter, WhatsApp), as well as utilitarian bots such as [Hookshot](https://github.com/matrix-org/matrix-hookshot) and [Draupnir](https://github.com/the-draupnir-project/Draupnir)

## Motivation and goals of this project

As someone with very basic docker-compose experience who wanted to get into the matrix "ecosystem", I found it difficult to find such easy setups such as this available.

For this reason (and because constructing my own docker-compose with ~35 services for my own HS took weeks), I wanted to provide a slightly easier way to selfhost your own Matrix HS without needing a sysadmin bachelor's degree.


The goals of matrix-compose are not to be a full-fledged and perfect production HS, but more-so a personal, small HS that people can experiment with, and learn about the matrix ecosystem with.

**If you are trying to host a production-grade large matrix HS, this is the wrong place!**



# Setup Guide

## Pre-requisites

* A Linux Server with at least 10Gb free disk space and ~2Gb RAM
> Resource usage will mostly depend on your usage

* A available domain behind a reverse proxy such as Cloudflare

* Linux, Docker, Docker-Compose and Git experience or willingless to google issues that arise



## Getting everything ready


### Dependencies

You need to install all the relevant tooling for the setup process, though the bulk of the services run on Docker, your host requires some setup.

install git, openssl, dig, curl
```sh
sudo apt-get update
sudo apt-get install -y openssl dig curl git
```

### Setup DNS and Routing

Before you proceed, it's best to decide how your DNS/Reverse Proxying will connect to your matrix HS.

matrix-compose was designed to be put behind a reverse proxy and will NOT be secure at all if not behind one.

[Cloudflare Tunnels](https://www.cloudflare.com/products/tunnel/) are recommended and supported for high flexibility and security environments.

#### Cloudflare Tunnels

If using Cloudflare Tunnels, simply create a new tunnel, copy the token shown on the "Install Connector" page and save it for later.

Add a single public hostname of `HTTPS://` `nginx:443` for the URL you are configuring your matrix HS to be available at.

__**Make sure to enable "No TLS Verify" on the tunnel settings**__ (or replace the self-signed generated certs at the end of the setup with Cloudflare Certs), otherwise the tunnel will refuse to connect to your Nginx backend.

#### DNS Records

Set the following DNS records on your domain's DNS management dashboard:

* **A** `example.org.` - ipv4 (if not using tunnels)

* **A** `turn.example.org.` - your server's IPv4 address (for VoIP)

* **AAAA** `turn.example.org.` - your server's IPv6 address (for VoIP)




## Installation

### Clone the repo

```sh
git clone https://github.com/metal0/matrix-compose.git
```

### Install Docker Engine (and Docker Compose)


Refer to the following guide on how to install these for your OS/Distro:
[https://docs.docker.com/engine/install/#server]

__Make sure to test your docker installation as mentioned in the guides before proceeding!__

### Setup Env Variables

Copy the `.env` file
```sh
cp .env.example .env
```


Then edit it with your favorite text editor, making sure to ONLY filling in `DOMAIN_NAME` (and `TUNNEL_TOKEN` if using Cloudflare Tunnels).
```bash
nano .env
```

### Run the Initialization Script

Finally, you need to run the initialization script `init.sh` which will setup everything else for you automatically.


```bash
chmod +x init.sh && ./init.sh
```

This will take several minutes to run and fully setup all services, don't panic.

> [!IMPORTANT]
> Some bridges and bots require additional setup post-install, refer to the guides below after everything is functional



## Firewalling

> Ports:
### Nginx

Nginx needs only port `443` allowed (if not using cloudflare tunnels)

### Eturnal (VoIP)

If you wish to use VoIP with Eturnal, you will need to allow the following ports:
> `3478`
> `5349`
> `49152-65535`
In addition, you should add your server's IPv6 address to `/data/eturnal/eturnal.yml`, and verify that VoIP is working using a tool such as [https://test.voip.librepush.net/]


## Customizing the Web Client

In order to customize the web-client to your liking, please refer to [Element Web's Documentation](https://github.com/vector-im/element-web/blob/develop/docs/config.md).
(Relevant config file is @ `/data/web-client/web-client.config.json`)

## Synapse Configuration

Synapse's config is found @ `/data/synapse/config.yaml`

### Enabling Public Registration

In order to safely enable public registration you will likely want to add either recaptcha or email verification (to prevent abuse).

> [!CAUTION]
> The Mautrix bridges are not configured for a multi-user setup (though they will allow anyone registered on your HS to use them)
> For this reason it's highly recommended to review your Mautrix bridge bots' configuration before enabling public registration


## Bot Setup

### Draupnir


Create a management room for Draupnir, make sure it's set to invite-only. (As anyone who joins the room can use the bot)
Give it the local alias `#draupnir`
Invite the bot to the room (`@draupnir:example.org`)
Restart the draupnir docker container `docker restart draupnir`
You should see it join the room!
[Quick-start guide](https://github.com/the-draupnir-project/Draupnir#quickstart-guide)


### Hookshot


Only Generic Webhooks and RSS/Atom feeds are configured and enabled by default
Bot: `@hookshot:example.org`

Check [hookshot documentation](https://matrix-org.github.io/matrix-hookshot/latest/hookshot.html) for usage/configuration guides.


### Bridges

Check the [mautrix bridge docs](https://docs.mau.fi/bridges/) to learn how to use & configure each mautrix bridge


#### Telegram Bridge

Create API keys at https://my.telegram.org/apps and optionally create a bot account for relaying at https://t.me/BotFather
Input the respective values @ `data/bridges/telegram/config.yaml` (`telegram.api_id`, `telegram.api_hash`, `telegram.bot_token`)

If using the bot relay, also add yourself to the `relaybot.whitelist` array in the config file.

After configuring, uncomment the line on synapse's config `app_service_config_files` relevant to the telegram registration file.
