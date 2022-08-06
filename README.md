# Docker-Rails

Application created to demo commands / process in
[Docker for Rails Developers].

See [Notes](docs/notes.md)

[Docker for Rails Developers]: https://pragprog.com/titles/ridocker/docker-for-rails-developers/

## Doctl

Docker images stored in DigitalOcean repository, accessed using [doctl],
the Digital Ocean CLI (command line interface).

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
