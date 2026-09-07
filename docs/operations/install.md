# Install

One-time setup for a machine. Everything after this runs without administrator
rights.

## Build

```sh
make
```

This produces `bin/containerctl`, `bin/containerdns` and
`bin/containerbar.app`.

## Set up the machine

Open the application and select **Finish setup**, or run:

```sh
bin/containerctl install
```

Three steps are applied:

| Step | Administrator rights |
| --- | --- |
| Write `/etc/resolver/<domain>` for each delegated domain | Required |
| Add the certificate authority to the user's trust settings | Not required |
| Register the DNS server as a launchd user agent | Not required |

The command line asks for the password with `sudo` on the terminal it was
started from. The application presents the system authentication panel and runs
the privileged step through the `containerctl` binary inside its bundle.

## Verify

```sh
bin/containerctl doctor
```

The command reports what is still missing and changes nothing. A machine that
is set up prints `nothing to do`.

## Put the binaries on PATH

```sh
ln -s "$PWD/bin/containerctl" /usr/local/bin/
ln -s "$PWD/bin/containerdns" /usr/local/bin/
```

`containerctl install` registers the launchd agent with the path of the
`containerdns` binary next to `containerctl`, so keep the two together.

## Remove

```sh
containerctl uninstall
security remove-trusted-cert -d ~/.containerctl/ca.crt
rm -rf ~/.containerctl
```

`uninstall` removes the resolver entries and the launchd agent. The certificate
authority stays in the trust settings until it is removed with the second
command. `docs/spec/machine-state.md` lists every path this tool creates.
