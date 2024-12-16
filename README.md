# HumHub - Docker Image (Development Version)

The Docker package provides all the essential components for setting up your HumHub installation.

## Features

- HumHub Core Software (Apache2 + FPM)
- MariaDB (Database Server)
- Caddy (Reverse Proxy w/ automatic LetsEncrypt SSL certificates)
- Redis (Cache / Queue)

## Quick Start

### Installation

```
git clone git@github.com:humhub/docker-dev.git /opt/humhub
cd /opt/humhub

cp humhub.env.dist humhub.env
cp .env.dist .env
```

Then edit the `.env` file and set at least the `HUMHUB_DOCKER_DOMAIN`.

```
docker compose up -d
```

> On older Docker versions you may need to run `docker-compose up -d` instead. 

Open your HumHub installation at: https://YOUR-HUMHUB_DOCKER_DOMAIN

> After installation, an e-mail server must be configured at: `Administration` -> `Settings` -> `Advanced` -> `E-Mail`.

### Upgrading

Running following commands in the main directory.

```
cd /opt/humhub

git pull

docker compose pull
docker compose down
docker compose up -d
```

> Also check for new configuration options in `.env.dist` and `humhub.env.dist` files.

## Other Setup Options

### HumHub CLI 

You can use the wrapper script in the main directoy.

```
./yii.sh help
```

### Version Control

You can define the HumHub version using the variable `HUMHUB_DOCKER_VERSION`. 

The following tags are currently available:
- ~~`master` - For the current stable version~~ (not available yet)
- `develop` - For the current development version
- `next` - For the next development version

For older versions:
- ~~`v1.17`~~ (not available yet)
- ~~`v1.17.0-beta.1`~~ (not available yet)

### Custom Themes & Modules

You can store your own themes/modules in the  folders `/opt/humhub/humhub-data/themes` and `/opt/humhub/humhub-data/custom-modules`. 

### Existing Reverse Proxy

**NGINX Example:** 

If an NGINX web server is already running on the host on which the Docker container is started on the HTTPS port, a reverse proxy to the HumHub Docker container can be created in a virtual host via the following block. 

```
   	location / {
		proxy_pass http://127.0.0.1:8404;
		proxy_set_header Host $http_host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
```    

**Apache2 Example:** 

TBD
