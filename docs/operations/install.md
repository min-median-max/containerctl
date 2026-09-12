# Install

One-time setup for a machine. Everything after this runs without administrator
rights.

Requirements: macOS with Apple `container` 1.3 or later, and Go 1.27 or later.
The application also needs the Xcode command line tools, which supply the
compiler for its AppKit layer.

## Command line only

```sh
go install github.com/min-median-max/containerctl/cmd/containerctl@latest
go install github.com/min-median-max/containerctl/cmd/containerdns@latest
```

Both binaries land in the same directory, which is what `containerctl install`
needs: it registers the DNS agent with the path of the `containerdns` beside
`containerctl`.

## Command line and application

```sh
git clone https://github.com/min-median-max/containerctl.git
cd containerctl
make
sudo make install
```

`make` produces `bin/containerctl`, `bin/containerdns` and
`bin/containerbar.app`. `make install` copies the two binaries to
`/usr/local/bin` and the application to `/Applications`.

Install elsewhere with `PREFIX` and `APPDIR`, which needs no `sudo` when the
directories belong to you:

```sh
make install PREFIX="$HOME/.local" APPDIR="$HOME/Applications"
```

`make uninstall` removes the installed files. It does not undo the machine
setup; run `containerctl uninstall` for that.

## Prebuilt downloads are not offered

A downloaded binary carries the quarantine attribute, and macOS terminates an
unsigned quarantined binary before it runs. Distributing a working download
requires an Apple Developer ID signature and notarization, which this project
does not have. Both paths above build on the machine, so nothing is
quarantined.

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

## Remove

```sh
containerctl uninstall
security remove-trusted-cert -d ~/.containerctl/ca.crt
rm -rf ~/.containerctl
sudo make uninstall          # in the clone, if make install was used
```

`uninstall` removes the resolver entries and the launchd agent. The certificate
authority stays in the trust settings until it is removed with the second
command. `docs/spec/machine-state.md` lists every path this tool creates.

## One machine, one setup

`-state` selects the directory holding the authority, the certificates and the
project registry. The resolver entries, the DNS agent and the proxy are the
machine's and there is one of each, so one state directory owns them.
`containerctl doctor` names the owner. A command run from another state
directory reads the machine but does not change its setup; it stops and says
whose it is. Take the setup over deliberately with `containerctl -state <dir>
install`.

## What asks for a password

Two steps ask, and they ask for different things.

- Writing `/etc/resolver/<domain>` needs administrator rights: `sudo` on the
  terminal, or the system authentication panel in the window.
- Trusting the authority needs no root and still asks. It writes to the login
  keychain, and macOS puts up its own trust-settings dialog for the login
  password.

Nothing else asks. Creating the authority and issuing certificates write inside
the state directory.

Neither is per command. A domain is delegated once and an authority is trusted
once, so a project served under a domain already delegated, from a state
directory whose authority is already trusted, runs with nothing on the screen.

`containerctl doctor` lists what is outstanding and says which of the two each
step asks for. Read it before running anything from a script: neither prompt can
be answered by a program with no one at the keyboard. Run `containerctl install`
once, with someone there to answer, and the commands after it need nothing.
