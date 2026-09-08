# keepsuit/gitlab-ci-node

Node CI image with Node, [nub](https://github.com/nubjs/nub), git and the
package-manager shims ready at process start.

| Tags | Contents |
| ---- | -------- |
| `24` | Node 24, nub |
| `26` | Node 26, nub |

## Usage

```yaml
test:
  image: keepsuit/gitlab-ci-node:24
  script:
    - pnpm install --frozen-lockfile
    - pnpm run build
```

`nub pm shim` runs while the image is built for the non-root `user`. The
`npm`, `npx`, `pnpm`, `pnpx`, `yarn` and `yarnpkg` commands therefore resolve
the package-manager version declared by the project's `packageManager` field
without a setup step in the job.

Projects without a `packageManager` pin still work: nub infers the version
from the committed lockfile and warns. `nub` itself is available for commands
such as `nub install` and `nubx ...`.

The image runs as the non-root `user`, which has passwordless `sudo`.

`corepack` is stubbed with a script that prints a warning and exits 0, so an
existing `corepack enable` step does not fail the job. Remove that step when
convenient.

## Building locally

```bash
docker build -f images/node/Dockerfile -t gitlab-ci-node:local \
  --build-arg NODE_VERSION=24 images
```

| Build arg        | Default  |
| ---------------- | -------- |
| `NODE_VERSION`   | `24`     |
| `NUB_VERSION`    | `latest` |
| `DEBIAN_VERSION` | `trixie` |
