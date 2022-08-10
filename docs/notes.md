# Notes

## Setup

I created a container from the default Ruby image, and generated the Rails
application.

```bash
# run ruby temporary container locally in interactive mode, with pseudo-terminal
docker run -i -t --rm -v ${PWD}:/usr/src/app ruby:3.0.4-buster bash

# install rails
gem install rails

# create rails application
rails new /usr/src/app --skip-hotwire --skip-bundle --skip-test --database=sqlite3
```

## Build Docker Image

Build a Docker Image from the Dockerfile

```bash
# build image
docker build .

# list images
docker images

# run container
docker run -p 3000:3000 274f7ecdaef2 bin/rails s -b 0.0.0.0
```

## Tagging Image

```bash
# tag image as 'railsapp' with 1.0 tag
docker tag 274f7ecdaef2 railsapp
docker tag railsapp railsapp:1.0

# build with tag
docker build -t railsapp -t railsapp:1.0 .

# run rails app (default command for image)
docker run -p 3000:3000 railsapp

# run rails app with rake task list output (override default command)
docker run --rm railsapp bin/rails -T
```

## Docker Compose

```bash
# bring up local docker nodes
docker-compose up

# bring up local docker nodes (detached mode)
docker-compose up -d

# shut down local docker nodes
docker-compose stop

# stop specific service (web)
docker-compose stop web

# start specific service (web)
docker-compose start web

# restart service
docker-compose restart web

# view container logs
docker-compose logs -f web

# run single command in container
docker-compose run --rm web echo 'ran a different command'

# run command on existing container
docker-compose exec web ls

# build container
docker-compose build web

# cleanup containers/images/resources
docker-compose rm
```

## Prune Images

```bash
# remove unused data
docker system prune

# remove unused data, all images, do not prompt for confirmation
docker system prune -af
```

## Redis and Postgres

```bash
# bring up redis service
docker-compose up -d redis

# bring up database service (postgres)
docker-compose up -d database

# view redis logs
docker-compose logs redis

# view postgres logs
docker-compose logs database

# view networks
docker network ls
```

## Volumes

```bash
# list volumes
docker volume ls
```

## Alternative Build

The Rails application could have been created as an API-only app with Webpacker
setup for the front-end.

```bash
rails new myapp --webpack=react --api --skip-hotwire --skip-jbuilder --skip-asset-pipeline --database=postgresql
```
