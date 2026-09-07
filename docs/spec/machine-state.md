# Machine state

Status: implemented.

This document lists everything `containerctl` creates outside its repository,
and how each item is removed.

## Files

| Path | Created by | Requires root | Removed by |
| --- | --- | --- | --- |
| `/etc/resolver/<domain>` | `install`, or `up` when a domain is new | Yes | `containerctl uninstall` |
| `~/Library/LaunchAgents/dev.containerctl.dns.plist` | `install` | No | `containerctl uninstall` |
| `~/.containerctl/ca.crt`, `ca.key` | First run that needs a certificate | No | Delete the directory |
| `~/.containerctl/certs/` | Each route | No | `Reissue all`, or delete the directory |
| `~/.containerctl/conf.d/stack.conf` | Each proxy sync | No | Regenerated on the next sync |
| `~/.containerctl/machine.json` | Domain changes | No | Delete the file |
| `~/.containerctl/groups.json` | Project registration | No | Delete the file |
| `~/.containerctl/logs/` | The launchd agent | No | Delete the directory |

## System state

| State | Set by | Requires root | Removed by |
| --- | --- | --- | --- |
| User trust setting for the certificate authority | `install` | No | `security remove-trusted-cert ~/.containerctl/ca.crt` |
| launchd user agent `dev.containerctl.dns` | `install` | No | `containerctl uninstall` |
| Appearance preference | The window's Auto/Dark/Light control | No | `defaults delete dev.containerctl.bar appearance` |

## Containers

| Name | Created by | Removed by |
| --- | --- | --- |
| `containerctl-edge` | Any command that produces routes | The last `down`, or `container rm -f containerctl-edge` |
| `<project>-<service>` | `up`, `start`, `restart` | `down` |

## Privilege

Writing under `/etc/resolver` requires root. Every other step runs as the user.

The command line acquires root with `sudo` on the terminal it was started from.
The application has no terminal and calls
`AuthorizationExecuteWithPrivileges`, which presents the system authentication
panel; the privileged step is executed by the `containerctl` binary inside the
application bundle.
