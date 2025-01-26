# matrix-compose

## What is it?

matrix-compose is a collection of scripts and config files intended to make setting up and configuring a small/personal [Matrix](https://matrix.org/) homeserver easier.


Included in the docker-compose services are, along with a working **unfederated** homeserver (Synapse) setup, various social media bridges (IRC, Bluesky, Discord, Facebook (Meta), Google Messages, Google Chat, Instagram, LinkedIn, Signal, Slack, Steam, Telegram, Twitter, WhatsApp), as well as utilitarian bots such as [Hookshot](https://github.com/matrix-org/matrix-hookshot)

> [!CAUTION]
> This branch (`unfed`)'s setup refers to a completely isolated & unfederated matrix server setup, which is only intended to be used for experimentation and for utilizing social platform bridge bots.
> This setup will NOT allow communication with other matrix homeservers, nor any "typical" usage of the matrix platform.


## Motivation and goals of this project

As someone with very basic docker-compose experience who wanted to get into the matrix "ecosystem", I found it difficult to find easy setups such as this available.

For this reason (and because constructing my own docker-compose with ~35 services for my own HS took weeks), I wanted to provide a slightly easier way to selfhost your own Matrix HS without needing a sysadmin bachelor's degree.

The goals of matrix-compose are not to be a full-fledged and perfect production HS, but more-so a personal, small HS that people can experiment with, and learn about the matrix ecosystem with.

**If you are trying to host a production-grade large matrix HS, this is the wrong place!**



# Setup Guide

## Pre-requisites

* A Linux Server with at least 10Gb free disk space and ~2Gb RAM
(Resource usage will mostly depend on your usage)

* Linux, Docker, Docker-Compose and Git experience or willingness to google issues that arise

* Tailscale account

## Getting everything ready


### Dependencies

You need to install all the relevant tooling for the setup process, though the bulk of the services run on Docker, your host requires some setup.

install git, openssl, dig, curl
```sh
sudo apt-get update
sudo apt-get install -y openssl dig curl git
```

### VPN Routing

matrix-compose (unfederated) was designed to be put behind the tailscale VPN, which provides us with free TLS certs and keeps our server isolated from the internet (as with any other VPN)

Register an account over at [Tailscale](https://login.tailscale.com/start), grab your [Tailnet Name](https://login.tailscale.com/admin/dns), [create auth keys](https://login.tailscale.com/admin/settings/keys), and [setup your own devices](https://tailscale.com/download) that will be used as clients for connecting to this matrix server.



## Installation

### Clone the repo

```sh
git clone -b unfed https://github.com/metal0/matrix-compose.git
```

### Install Docker Engine (and Docker Compose)


Refer to the following guide on how to install these for your OS/Distro:
https://docs.docker.com/engine/install/#server

__Make sure to test your docker installation as mentioned in the guides before proceeding!__

### Setup Env Variables

Copy the `.env` file
```sh
cp .env.example .env
```


Then edit it with your favorite text editor, making sure to ONLY filling in `TS_AUTHKEY` and `TS_TAILNET`).
```bash
nano .env
```

### Run the Initialization Script

Finally, you need to run the initialization script `init.sh` which will setup everything else for you automatically.


```bash
sh init.sh
```

This will take several minutes to run and fully setup all services, don't panic.

> [!IMPORTANT]
> Some bridges/bots require additional setup post-install, refer to the guides below after everything is functional



## Firewalling

### Nginx

Nginx needs only port `443` allowed (if not using cloudflare tunnels)

## Customizing the Web Client

In order to customize the web-client to your liking, please refer to [Element Web's Documentation](https://github.com/vector-im/element-web/blob/develop/docs/config.md).
(Relevant config file is @ `/data/web-client/web-client.config.json`)

## Synapse Configuration

Synapse's config is found @ `/data/synapse/config.yaml`

The included config shouldn't need any major changes.

### Enabling Public Registration

In order to safely enable public registration you will likely want to add either recaptcha or email verification (to prevent abuse).


## Bot Setup

### Bot Localparts

* Discord: `@mautrix-discordbot:example.org`
* Meta: `@mautrix-metabot:example.org`
* Gmessages: `@mautrix-gmessagesbot:example.org`
* Googlechat: `@mautrix-googlechatbot:example.org`
* Heisenbridge: `@heisenbridge:example.org`
* Hookshot: `@hookshot:example.org`
* Instagram: `@mautrix-instagrambot:example.org`
* LinkedIn: `@beeper-linkedinbot:example.org`
* Signal: `@mautrix-signalbot:example.org`
* Slack: `@mautrix-slackbot:example.org`
* Steam: `@_steampuppet_bot:example.org`
* Telegram: `@mautrix-telegrambot:example.org`
* Twitter: `@mautrix-twitterbot:example.org`
* WhatsApp: `@mautrix-whatsappbot:example.org`


### Hookshot

Hookshot is a bridge between multiple project management services (Github, Gitlab, Jira, etc) as well as a webhooks provider and rss feeds tracker.
By default Hookshot is only configured to handle generic webhooks and RSS/Atom feeds, anything else needs to be configured manually.

Bot: `@hookshot:example.org`

Check [hookshot documentation](https://matrix-org.github.io/matrix-hookshot/latest/hookshot.html) for usage/configuration guides.


### Bridges

Check the [mautrix bridge docs](https://docs.mau.fi/bridges/) to learn how to use & configure each mautrix bridge


#### Telegram Bridge

Create API keys at https://my.telegram.org/apps and optionally create a bot account for relaying at https://t.me/BotFather
Input the respective values @ `data/bridges/telegram/config.yaml` (`telegram.api_id`, `telegram.api_hash`, `telegram.bot_token`)

If using the bot relay, also add yourself to the `relaybot.whitelist` array in the config file.

After configuring, uncomment the line on synapse's config `app_service_config_files` relevant to the telegram registration file.


# Contributing

All contributions are welcome!
