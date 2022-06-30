playSMS Container Image
==============

playSMS version 1.4.5

This repository contains build files for a simplified and modernized container image of playSMS. 
playSMS is a free and open source SMS gateway software.

Visit [playSMS](http://playsms.org) website for more information.

## Build

First build the container image from this repo:
```
docker build -f Containerfile -t localhost/playsms:1.4.5
```

## Run

A fully automated application init is done using Docker Compose:
```
docker-compose up
```

Default Port: `8080`
Default Login: `admin:admin`

## Config

You need to fetch a basic config file by cat into the playsms-server container:
```
docker run --rm --entrypoint cat localhost/playsms:1.4.5 /var/www/html/config.php > config.php
```

Throw an additional volume into the playsms container after tweaking your newly obtained config file:
```
config.php:/var/www/html/config.php:ro
```

## Maintainer

- [Robert Zaage](https://zaage.it)

That's all!
