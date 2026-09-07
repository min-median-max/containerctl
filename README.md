# containerctl

`containerctl` runs Compose projects on Apple `container` and serves each
service over HTTPS at a local domain name. No host port is published, and no
entry is added to `/etc/hosts`.

A project is a Compose file. A service with no extra settings is served at
`<service>.test`.

## Start

```sh
go install github.com/min-median-max/containerctl/cmd/containerctl@latest
go install github.com/min-median-max/containerctl/cmd/containerdns@latest
containerctl install         # once per machine; asks for the password
cd ~/work/your-project
containerctl up
```

For the menu bar application as well, clone this repository and run `make`
then `sudo make install`. See [Install](docs/operations/install.md).

## Usage instructions live in the commands

```sh
containerctl brief           # the whole usage contract, --json for programs
containerctl schema          # the Compose file contract, --json for programs
containerctl help up         # what one command changes
containerctl status --json   # the current machine state
```

A project that installs the binaries does not receive this repository, so the
commands carry the instructions.

## Documents

| Document | Content |
| --- | --- |
| [Install](docs/operations/install.md) | One-time machine setup and how to remove it |
| [Using](docs/operations/using.md) | Adding a project, domains, ports, daily commands |
| [Troubleshooting](docs/operations/troubleshooting.md) | Symptom, cause, action |
| [Architecture](docs/spec/architecture.md) | Components, request path, routing state |
| [Command contract](docs/spec/cli.md) | Commands, effects, rules, diagnostics |
| [Compose contract](docs/spec/compose-schema.md) | Keys, labels, port resolution |
| [Machine state](docs/spec/machine-state.md) | Every path created outside this repository |
| [Features](docs/features.md) | Implementation status and verification |
| [Changelog](CHANGELOG.md) | Behavior changes and their verification |
| [Documentation plan](docs/documentation-plan.md) | Where each kind of information is written |
| [Development](AGENTS.md) | Building, testing and the required checks |

Korean documents carry the suffix `.ko.md`.

## Requirements

macOS with Apple `container` 1.3 or later, and Go 1.27 or later. The
application also needs the Xcode command line tools.
