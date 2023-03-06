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

## Tagging for an Alternative Registry

I'm wanting to use Digital Ocean's container registry to host my Docker images.
It appears that I just need to tag them to include the docker registry server
hostname.

```bash
$ doctl registry login
Logging Docker in to registry.digitalocean.com

$ docker build -f Dockerfile.prod -t registry.digitalocean.com/redconfetti/rails_app:prod .

$ docker image ls
REPOSITORY                                        TAG       IMAGE ID       CREATED          SIZE
registry.digitalocean.com/redconfetti/rails_app   prod      81a99b625c6e   14 seconds ago   1.2GB

$ docker push registry.digitalocean.com/redconfetti/rails_app:prod
```

## Docker Machine

On page 156 of _Docker for Rails Developers_ it instructs to run the command
`docker-machine-create --driver virtualbox local-vm-1`. This command, intended
to help you setup a Docker Engine node locally under Virtualbox, is no
longer supported.

Although [Docker Machine][] made it easy to provision Docker Engine servers
for many cloud providers, it's main purpose was to support provisioning
the [Boot2Docker] image under a Virtualbox guest machine. Once Docker Desktop
was able to run natively on Mac and Windows machines, this functionality was
no longer needed, and thus was [deprecated].

> Machine was the only way to run Docker on Mac or Windows previous to Docker
> v1.12. Starting with the beta program and Docker v1.12, Docker Desktop for
> Mac and Docker Desktop for Windows are available as native apps and the
> better choice for this use case on newer desktops and laptops.

Note: Docker v1.12 also introduced swarm mode.

To help provide an equivalent, I've created [local-docker] to help developers
create Docker Engines under Virtualbox locally to experiment with Docker Swarm.

[deprecated]: https://github.com/docker/machine/issues/4537
[docker machine]: https://github.com/docker/machine
[the toolbox was deprecated]: https://github.com/docker-archive/toolbox/blob/b70faff6/README.md
[boot2docker]: https://github.com/boot2docker/boot2docker
[local-docker]: https://github.com/redconfetti/local-docker

## Docker Swarm

Some features from Docker Machined moved under the `docker swarm` feature.

```shell
# docker-machine init becomes
docker swarm init

# docker-machine join becomes
docker swarm join
```

### References

* [Swarm Mode Overview][]
* [Swarm Mode Key Concepts][]
* [Swarm Tutorial][]

[Swarm Mode Overview]: https://docs.docker.com/engine/swarm/
[swarm mode key concepts]: https://docs.docker.com/engine/swarm/key-concepts/
[Swarm Tutorial]: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

## Podman

Docker charges for certain services, and so a movement to create open source
equivalents have mobilized. One replacement, for developers to use, is
to use [Podman Desktop][] instead of [Docker Desktop][].

```shell
brew install podman-desktop
```

[podman desktop]: https://podman-desktop.io/
[docker desktop]: https://www.docker.com/products/docker-desktop/

## Deploying Swarm

```bash
$ docker stack deploy -c docker-stack.yml rails_app
Creating network rails_app_default
Creating service rails_app_web
Creating service rails_app_redis
Creating service rails_app_database

$ docker stack services rails_app
ID             NAME                    MODE         REPLICAS   IMAGE                                                  PORTS
q23mtpmqb96d   rails_app_database      replicated   1/1        postgres:latest                                        
n1g5fr3ddquz   rails_app_db-migrator   replicated   0/1        registry.digitalocean.com/redconfetti/rails_app:prod   
lrdl782x2ff3   rails_app_redis         replicated   1/1        redis:latest                                           
j7j3svit6wgy   rails_app_web           replicated   1/1        registry.digitalocean.com/redconfetti/rails_app:prod   *:80->3000/tcp

$ docker stack rm rails_app
Removing service rails_app_database
Removing service rails_app_db-migrator
Removing service rails_app_redis
Removing service rails_app_web
Removing network rails_app_default

$ docker service logs rails_app_web
rails_app_web.1.g4tzcqstd323@docker-desktop    | => Booting Puma
rails_app_web.1.g4tzcqstd323@docker-desktop    | => Rails 7.0.3.1 application starting in production 
rails_app_web.1.g4tzcqstd323@docker-desktop    | => Run `bin/rails server --help` for more startup options
rails_app_web.1.g4tzcqstd323@docker-desktop    | Puma starting in single mode...
rails_app_web.1.g4tzcqstd323@docker-desktop    | * Puma version: 5.6.4 (ruby 3.0.4-p208) ("Birdie's Version")
rails_app_web.1.g4tzcqstd323@docker-desktop    | *  Min threads: 5
rails_app_web.1.g4tzcqstd323@docker-desktop    | *  Max threads: 5
rails_app_web.1.g4tzcqstd323@docker-desktop    | *  Environment: production
rails_app_web.1.g4tzcqstd323@docker-desktop    | *          PID: 1
rails_app_web.1.g4tzcqstd323@docker-desktop    | * Listening on http://0.0.0.0:3000
rails_app_web.1.g4tzcqstd323@docker-desktop    | Use Ctrl-C to stop
```

I'm noticing that my stack is not deploying to the Vagrant managed servers
but instead `@docker-desktop`.
