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

## Docker Machine Deprecated

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

With Docker Desktop, you can deploy a swarm to the Docker Engine that is running
natively on your own system.

If you really wish to setup a multi-node swarm locally using Virtualbox, 
I've created [local-docker] to help developers provision Docker Engines under
Virtualbox locally to experiment with Docker Swarm.

### Docker Contexts

You'll notice on Page 158, and pages thereafter, the `docker-machine env`
command is used several times to output the environment variables used by the
Docker client to connect to the local "Docker Machine".

This functionality has been replaced by [Docker Contexts][].

With any machine you setup running the Docker Engine (also known as ContainerD),
there isn't going to be a public API or port exposed on the machine for your
Docker client to connect to. Instead you should use SSH to connect to a Docker
Engine node.

Here are the commands I used to configure a Docker context for the first node
managed by my [local-docker] Vagrant setup.

```shell
# list current contexts
docker context list

# test ssh into server and accept ECDSA key
ssh -l vagrant -- 192.168.50.2

# create new context using local docker node
docker context create vagrant-stack \
  --default-stack-orchestrator=swarm \
  --docker host=ssh://vagrant@192.168.50.2

# switch to the new context
docker context use vagrant-stack

# list docker services
docker ps
# should return "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES"
```

[deprecated]: https://github.com/docker/machine/issues/4537
[docker machine]: https://github.com/docker/machine
[the toolbox was deprecated]: https://github.com/docker-archive/toolbox/blob/b70faff6/README.md
[boot2docker]: https://github.com/boot2docker/boot2docker
[local-docker]: https://github.com/redconfetti/local-docker
[docker contexts]: https://docs.docker.com/engine/context/working-with-contexts/

## Registry Authentication

Because I decided to use a Digital Ocean registry, instead of using the Docker
Hub, I have to setup authentication for each context also.

```shell
$ docker context list
NAME              TYPE  DESCRIPTION                               DOCKER ENDPOINT                               ORCHESTRATOR
default *         moby  Current DOCKER_HOST based configuration   unix:///var/run/docker.sock                   swarm
desktop-linux     moby                                            unix:///Users/jason/.docker/run/docker.sock
rpi               moby                                            ssh://jason@192.168.1.51                      swarm
vagrant-stack *   moby                                            ssh://vagrant@192.168.50.2                    swarm

$ doctl auth init --context rpi
Please authenticate doctl for use with your DigitalOcean account. You can generate a token in the control panel at https://cloud.digitalocean.com/account/api/tokens

❯ Enter your access token:  ●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●

Validating token... ✔

$ doctl registry login --context rpi
Logging Docker in to registry.digitalocean.com

$ docker context use rpi
rpi
Current context is now "rpi"
```

## Docker Swarm

Page 160 instructs me to initialize a Swarm. I'm doing this against two Vagrant
boxes like so:

```shell
# change to vagrant-stack context
$ docker context use vagrant-stack
vagrant-stack
Current context is now "vagrant-stack"

$ docker swarm init --advertise-addr 192.168.50.2
Swarm initialized: current node (x2jx5ehpepaij5mti2fw3903s) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4bhhgc9676mqk8jtgio9tp3kymjawvy070fhgypuje3mjg3lz9-2nnjpfenyxutedcusddumm2h4 192.168.50.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

# log into my second vagrant box
$ ssh -l vagrant -- 192.168.50.3

$ docker swarm join --token SWMTKN-1-4bhhgc9676mqk8jtgio9tp3kymjawvy070fhgypuje3mjg3lz9-2nnjpfenyxutedcusddumm2h4 192.168.50.2:2377
This node joined a swarm as a worker.

# exit SSH session with second vagrant box (now swarm worker)
$ exit
```

### References

* [Swarm Mode Overview][]
* [Swarm Mode Key Concepts][]
* [Swarm Tutorial][]

[Swarm Mode Overview]: https://docs.docker.com/engine/swarm/
[swarm mode key concepts]: https://docs.docker.com/engine/swarm/key-concepts/
[Swarm Tutorial]: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

## Rebuild Image

Page 165 has us switch back to our local Docker Engine context

```shell
$ docker context use default
default
Current context is now "default"

$ docker build -f Dockerfile.prod -t registry.digitalocean.com/redconfetti/rails_app:prod .
[+] Building 19.9s (20/20) FINISHED                                                                                                                                     
 => [internal] load build definition from Dockerfile.prod                                                                                                          0.0s
 => => transferring dockerfile: 42B                                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                                  0.0s
 => => transferring context: 34B                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/ruby:3.0.4-buster                                                                                               0.9s
 => [auth] library/ruby:pull token for registry-1.docker.io                                                                                                        0.0s
 => [ 1/13] FROM docker.io/library/ruby:3.0.4-buster@sha256:280c82531e1a92e9843be59275985f25f1c6d129dde25e63bd7b0c3060f54e3c                                       0.0s
 => [internal] load build context                                                                                                                                  1.4s
 => => transferring context: 1.34MB                                                                                                                                1.3s
 => https://dl.yarnpkg.com/debian/pubkey.gpg                                                                                                                       0.1s
 => CACHED [ 2/13] RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -                                                                                     0.0s
 => CACHED [ 3/13] ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg                                                                               0.0s
 => CACHED [ 4/13] RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg                                                                                 0.0s
 => CACHED [ 5/13] RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list                                                    0.0s
 => CACHED [ 6/13] RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends     netcat     nodejs     yarn                                          0.0s
 => CACHED [ 7/13] RUN mkdir -p /usr/src/app                                                                                                                       0.0s
 => CACHED [ 8/13] COPY Gemfile* /usr/src/app                                                                                                                      0.0s
 => CACHED [ 9/13] WORKDIR /usr/src/app                                                                                                                            0.0s
 => CACHED [10/13] RUN bundle install                                                                                                                              0.0s
 => [11/13] COPY . /usr/src/app                                                                                                                                    4.3s
 => [12/13] RUN ["chmod", "+x", "/usr/src/app/wait-for"]                                                                                                           0.2s
 => [13/13] RUN bin/rails assets:precompile                                                                                                                       11.1s
 => exporting to image                                                                                                                                             1.8s
 => => exporting layers                                                                                                                                            1.8s
 => => writing image sha256:b90d2ea193d91b2b98cb24123b74ab0ded8baf822d43347a7bdd7511ba1a414f                                                                       0.0s
 => => naming to registry.digitalocean.com/redconfetti/rails_app:prod

$ docker push registry.digitalocean.com/redconfetti/rails_app:prod
The push refers to repository [registry.digitalocean.com/redconfetti/rails_app]
3bace8804751: Preparing 
f5691a0edcfc: Preparing 
0d404608f930: Preparing 
0d404608f930: Pushed 
5f70bf18a086: Layer already exists 
073ea7389491: Layer already exists 
dc046bc73f5d: Layer already exists 
f2351aef3969: Layer already exists 
b975e052b8fc: Layer already exists 
0f695abd41a2: Layer already exists 
30452d5339bd: Layer already exists 
57a44eaf473e: Layer already exists 
25e1365fc627: Layer already exists 
412573d0ce65: Layer already exists 
2d5f979f96b5: Layer already exists 
371dda325867: Layer already exists 
381f4f0a6ea8: Layer already exists 
155c77c325cb: Layer already exists 
4d19f53ef378: Layer already exists 
d6dff9eed369: Layer already exists 
prod: digest: sha256:1ed96f14d206a8564397f39c6ca5521cd9422af10c2021412c6674bc8295a19f size: 4516
```

## Deploying Swarm

Okay let's deploy this swarm.

```bash
$ docker context use vagrant-stack
vagrant-stack
Current context is now "vagrant-stack"

$ docker stack deploy -c docker-stack.yml rails_app
Creating network rails_app_default
Creating service rails_app_database
Creating service rails_app_web
Creating service rails_app_db-migrator
Creating service rails_app_redis

# why aren't my web and migrators running?
$ docker service ls
ID             NAME                    MODE         REPLICAS   IMAGE                                                  PORTS
itvfawmm66nr   rails_app_database      replicated   1/1        postgres:latest                                        
igbrinvzg2ir   rails_app_db-migrator   replicated   0/1        registry.digitalocean.com/redconfetti/rails_app:prod   
347jg25gqw7j   rails_app_redis         replicated   1/1        redis:latest                                           
xg7s6r2yy43b   rails_app_web           replicated   0/1        registry.digitalocean.com/redconfetti/rails_app:prod   *:80->3000/tcp

# ooh... not recognizing the digital ocean registry
$ docker service ps rails_app_web
ID             NAME                  IMAGE                                                  NODE      DESIRED STATE   CURRENT STATE             ERROR                              PORTS
wm4li3taihvg   rails_app_web.1       registry.digitalocean.com/redconfetti/rails_app:prod   docker    Ready           Rejected 1 second ago     "No such image: registry.digit…"   
ma9okhiiimja    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker2   Shutdown        Rejected 5 seconds ago    "No such image: registry.digit…"   
ps21bvntju4m    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker    Shutdown        Rejected 11 seconds ago   "No such image: registry.digit…"   
4olk5pjhb5sd    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker2   Shutdown        Rejected 15 seconds ago   "No such image: registry.digit…"   
ujofzyj2c20h    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker    Shutdown        Rejected 21 seconds ago   "No such image: registry.digit…"

$ doctl auth list
default (current)
redconfettti
rpi
vagrant-stack

# looks like I need to switch contexts using doctl also
$ doctl auth switch vagrant-stack
Now using context [default] by default

$ doctl registry login
Logging Docker in to registry.digitalocean.com

# now they're up
$ docker service ls
ID             NAME                    MODE         REPLICAS   IMAGE                                                  PORTS
itvfawmm66nr   rails_app_database      replicated   1/1        postgres:latest                                        
igbrinvzg2ir   rails_app_db-migrator   replicated   0/1        registry.digitalocean.com/redconfetti/rails_app:prod   
347jg25gqw7j   rails_app_redis         replicated   1/1        redis:latest                                           
xg7s6r2yy43b   rails_app_web           replicated   1/1        registry.digitalocean.com/redconfetti/rails_app:prod   *:80->3000/tcp

$ docker service logs rails_app_web
rails_app_web.1.i3jhrq48bspx@docker    | => Booting Puma
rails_app_web.1.i3jhrq48bspx@docker    | => Rails 7.0.3.1 application starting in production 
rails_app_web.1.i3jhrq48bspx@docker    | => Run `bin/rails server --help` for more startup options
rails_app_web.1.i3jhrq48bspx@docker    | Puma starting in single mode...
rails_app_web.1.i3jhrq48bspx@docker    | * Puma version: 5.6.4 (ruby 3.0.4-p208) ("Birdie's Version")
rails_app_web.1.i3jhrq48bspx@docker    | *  Min threads: 5
rails_app_web.1.i3jhrq48bspx@docker    | *  Max threads: 5
rails_app_web.1.i3jhrq48bspx@docker    | *  Environment: production
rails_app_web.1.i3jhrq48bspx@docker    | *          PID: 1
rails_app_web.1.i3jhrq48bspx@docker    | * Listening on http://0.0.0.0:3000
rails_app_web.1.i3jhrq48bspx@docker    | Use Ctrl-C to stop

$ docker service ps rails_app_web
ID             NAME                  IMAGE                                                  NODE      DESIRED STATE   CURRENT STATE            ERROR                              PORTS
i3jhrq48bspx   rails_app_web.1       registry.digitalocean.com/redconfetti/rails_app:prod   docker    Running         Running 3 minutes ago                                       
mtv2ondfjx4k    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker2   Shutdown        Rejected 3 minutes ago   "No such image: registry.digit…"   
ne0jtk7jiuf4    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker    Shutdown        Rejected 3 minutes ago   "No such image: registry.digit…"   
uu40383ewv24    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker2   Shutdown        Rejected 3 minutes ago   "No such image: registry.digit…"   
6oz79b3z4301    \_ rails_app_web.1   registry.digitalocean.com/redconfetti/rails_app:prod   docker    Shutdown        Rejected 3 minutes ago   "No such image: registry.digit…"
```

I visited http://192.168.50.2/welcome and I got the page. It's working!

```shell
$ docker stack ls
NAME        SERVICES   ORCHESTRATOR
rails_app   4          Swarm

$ docker stack services rails_app
ID             NAME                    MODE         REPLICAS   IMAGE                                                  PORTS
itvfawmm66nr   rails_app_database      replicated   1/1        postgres:latest                                        
igbrinvzg2ir   rails_app_db-migrator   replicated   0/1        registry.digitalocean.com/redconfetti/rails_app:prod   
347jg25gqw7j   rails_app_redis         replicated   1/1        redis:latest                                           
xg7s6r2yy43b   rails_app_web           replicated   1/1        registry.digitalocean.com/redconfetti/rails_app:prod   *:80->3000/tcp

$ docker stack rm rails_app
Removing service rails_app_database
Removing service rails_app_db-migrator
Removing service rails_app_redis
Removing service rails_app_web
Removing network rails_app_default
```
