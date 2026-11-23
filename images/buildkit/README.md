# keepsuit/gitlab-ci-buildkit

`moby/buildkit` with `jq`, `moreutils` and `aws-cli` preinstalled, for the
`docker-buildkit` template in `keepsuit/ci-templates`. The rootless variant
runs as uid 1000 and cannot `apk add` at job time, which is why the tools are
baked in.

| Tags                               | Runs as  | Runner needs                                 |
| ---------------------------------- | -------- | -------------------------------------------- |
| `rootless`, `<version>-rootless`   | uid 1000 | AppArmor `Unconfined` on the build container |
| `root`, `<version>-root`           | root     | `privileged = true`                          |

`rootless` and `root` follow the latest BuildKit release. `<version>` is the
BuildKit minor, e.g. `v0.34`, and follows its patch releases. The weekly
rebuild overwrites all tags with Alpine security updates.

## Rootless

Start the daemon with `--oci-worker-no-process-sandbox`: without it BuildKit
needs a new PID namespace and `/proc` mount that an unprivileged pod cannot
create.

```bash
BUILDKITD_FLAGS=--oci-worker-no-process-sandbox buildctl-daemonless.sh build ...
```

On Ubuntu 24.04 nodes the default AppArmor profile stops `rootlesskit` with
`failed to share mount point: /: permission denied`. The pod needs
`appArmorProfile: Unconfined`, but not `privileged`.

## Upgrading BuildKit

Bump the `FROM` line in both `Dockerfile` and `rootless.Dockerfile` (dependabot
does it) and merge: `ci-templates` uses the floating tags and picks it up. The
tag version is read from `Dockerfile`. If an upgrade breaks, pin `ci-templates`
to the previous `<version>-*` tag, which stays on Docker Hub.

## Building locally

```bash
docker build -f images/buildkit/rootless.Dockerfile -t gitlab-ci-buildkit:rootless images/buildkit
```
