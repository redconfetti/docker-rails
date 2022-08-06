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

## Prune Images

```bash
docker system prune -af
```
