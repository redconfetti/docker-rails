# Docker-Rails

Application created to demo commands / process in
[Docker for Rails Developers].

See [Notes](docs/notes.md)

[Docker for Rails Developers]: https://pragprog.com/titles/ridocker/docker-for-rails-developers/

## Setup

Install [Docker Desktop] using [Homebrew]

```bash
brew install --cask docker
```

With a single command the multiple Docker containers needed to run your
application are brought up and running:

```bash
# Bring up all docker containers in detached mode
docker-compose up -d
```

[Docker Desktop]: https://formulae.brew.sh/cask/docker
[Homebrew]: https://brew.sh/

## Docker Intro

[Docker] is a platform that enables you to containerize and share any
application on any cloud platform, in multiple languages and frameworks.

A public registry of Docker images is made available via [Docker Hub], and the
Docker Desktop software provides a local environment, and tools used to build
and manage Docker containers, images, volumes, etc.

* Containers - Encapsulated environment that runs applications, similar to a
  virtual machine
* Images - Snapshots of the filesystem used in a Docker container, made up of
  multiple layers. Your own images might be based on an official base image,
  such as the [official Ruby image], which is Ubuntu with Ruby installed. Your
  own Ruby on Rails application files would be stored as a separate layer
  added on top of the parent Ruby image.
* Volumes - Used to store data that must persist despite containers being
  brought down and brought back up. Used often with database containers.

[Docker-Compose] is used to define multiple nodes that run in a virtual network
on your local machine, defined in `docker-compose.yml`. This is intended for
configuring your local development environment.

[Docker-Machine] is a used for provisioning and managing your Dockerized hosts
(hosts with Docker Engine on them). It can be used to setup a Dockerized host
locally [using Virtualbox], or [provisioning remotely] on cloud platforms like
AWS and Digital Ocean. There is also a [generic] driver for virtual private
servers via SSH.

Managing production deployments of your application can be [orchestrated] using
[Docker Swarm] (simpler) or Kubernetes (steep learning curve).

[Docker]: https://docs.docker.com/get-started/overview/
[Docker Hub]: https://hub.docker.com/
[official Ruby image]: https://hub.docker.com/_/ruby
[Docker-Compose]: https://docs.docker.com/compose/
[Docker-Machine]: https://docker-docs.netlify.app/machine/overview/
[using Virtualbox]: https://docker-docs.netlify.app/machine/get-started/
[provisioning remotely]: https://docker-docs.netlify.app/machine/get-started-cloud/#examples
[generic]: https://docker-docs.netlify.app/machine/drivers/generic/
[orchestrated]: https://docs.docker.com/get-started/orchestration/
[Docker Swarm]: https://docs.docker.com/get-started/swarm-deploy/

## Common CLI Commands

```bash
# Run rspec tests
docker-compose exec web bin/rails spec
```

## Managing Containers

```bash
# Stop all docker containers
docker-compose stop

# Rebuild primary 'web' image
# (needed after making changes to Dockerfile)
docker-compose build web

# Recreate 'web' container from rebuild image
docker-compose up -d web

# Force recreation of 'web' container
docker-compose up -d --force-recreate web

# restart node
docker-compose restart web
docker-compose restart weboack_dev_server

# view logs for container
docker-compose logs -f web

# run command on existing container
docker-compose exec web ls -la
docker-compose exec web bin/rails -T

# remove containers/images/resources
docker-compose rm

# view virtual networks
docker network ls

# list volumes
docker volume ls

# remove unused data
docker system prune
```

## Notes

A 'db_data' volume is defined and used with the PostgreSQL container in
`docker-compose.yml`. This ensures that data is not lost when destroying
and recreating the 'database' container.

## Doctl

Note: This is not yet in use for this project

Docker images can be stored in a DigitalOcean repository, accessed using
[doctl], the Digital Ocean CLI (command line interface).

```bash
# install doctl
brew install doctl

# add an account auth with named context
doctl auth init --context redconfetti

# confirm connection to account
doctl account get

# authenticate with registry
doctl registry login
```

[doctl]: https://docs.digitalocean.com/reference/doctl/
