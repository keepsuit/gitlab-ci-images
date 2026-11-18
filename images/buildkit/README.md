# keepsuit/gitlab-ci-buildkit

`moby/buildkit` with `jq`, `moreutils` and `aws-cli` preinstalled, for the
`docker-buildkit` template in `keepsuit/ci-templates`. The rootless variant
runs as uid 1000 and cannot `apk add` at job time, which is why the tools are
baked in.

| Tags                 | Runs as  | Runner needs                                    |
| -------------------- | -------- | ----------------------------------------------- |
| `<version>-rootless` | uid 1000 | AppArmor `Unconfined` on the build container    |
| `<version>-root`     | root     | `privileged = true`                             |

`<version>` is the BuildKit release, e.g. `v0.34.2`. The weekly rebuild
overwrites the same tag with Alpine security updates.

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
does it), merge, then move the tag in `ci-templates`. The tag version is read
from `Dockerfile`. Old tags stay on Docker Hub as a rollback.

## Building locally

```bash
docker build -f images/buildkit/rootless.Dockerfile -t gitlab-ci-buildkit:rootless images/buildkit
```
