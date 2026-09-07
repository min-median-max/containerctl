# Using containerctl

Adding a project, running it, and the daily commands.

## Add a project

A project is a Compose file. A service with no extra settings is served at
`<service>.<machine default domain>`.

```yaml
name: shop

services:
  web:
    image: node:26-slim
    ports: ["3000"]
    command: ["npm", "run", "dev"]

  db:
    image: postgres:18
    expose: ["5432"]
    environment:
      POSTGRES_PASSWORD: dev
    labels:
      containerctl.internal: "true"
```

```sh
cd ~/work/shop
containerctl up
```

`https://web.test/` is served. `db` runs without a domain because it is marked
internal.

Run `containerctl schema` for every key this tool reads.

## Domains

A domain is delegated once per machine. A project uses the machine default
unless its Compose file pins one:

```yaml
x-containerctl:
  domain: shop.test
```

Add or remove machine domains in the application's **Domains** screen. Adding a
domain writes an `/etc/resolver` entry and asks for the password once.

A domain with two labels, such as `shop.test`, also gives a valid wildcard
certificate for names that have no route. A single-label domain such as `test`
does not, so a mistyped name produces a certificate warning instead of a 404.

## Ports

The container port is read from the first of:

1. the `containerctl.port` label;
2. the first entry of `expose`;
3. the container side of the first entry of `ports`;
4. 80.

Host ports are ignored. Each container has its own address, so nothing is
published to the host.

## Service to service

Reach another service at `<project>-<service>.container.test:<port>`:

```yaml
    environment:
      DATABASE_URL: postgres://shop-db.container.test:5432/app
```

Container addresses change on every start, so use the name.

## Daily commands

```sh
containerctl up                 # start the project and register its routes
containerctl down               # remove the project and withdraw its routes
containerctl restart web        # one service
containerctl stop db            # keep the container, withdraw the route
containerctl logs -f web        # follow the output
containerctl status             # the proxy and every registered project
containerctl status --json      # the same, for another program
containerctl doctor             # what setup is missing
```

The application performs the same actions. The project screen carries Start,
Restart and Stop for the project; each service row carries Start, Stop and
Logs.

## Onboarding another person

Commit the Compose file. Do not commit certificates or keys: each machine issues
its own from its own authority.

```sh
git clone ... && cd shop
containerctl up
```

The first `up` asks for the password when the project uses a domain the machine
does not delegate yet.
