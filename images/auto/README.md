# keepsuit/gitlab-ci-auto

The opposite of the PHP image: nothing is baked in except
[mise](https://mise.jdx.dev), which provisions whatever the project pins. Meant
for deploy jobs and projects that need tools such as aws-cli, helm or kubectl.

| Tags     | Contents        |
| -------- | --------------- |
| `latest` | mise, git, curl |

## Usage

Put a `mise.toml` in the repo and install it in the job:

```yaml
deploy:
  image: keepsuit/gitlab-ci-auto
  script:
    - mise install
    - helm upgrade --install myapp ./chart
```

```toml
# mise.toml
[tools]
node = "24"
kubectl = "latest"
helm = "latest"
"aws-cli" = "latest"
```

`mise install` puts shims in `~/.local/share/mise/shims`, which is already on
`PATH`, so tools resolve as bare commands — no `mise activate`, no `mise exec`
wrapper. `mise activate` relies on a shell hook that a non-interactive CI shell
never runs, which is why the image sets `PATH` directly instead.

`MISE_TRUSTED_CONFIG_PATHS=/builds` and `MISE_YES=1` are set so nothing blocks
on the trust prompt mise would otherwise show for a freshly cloned config.

The image runs as the non-root `user`, which has passwordless `sudo`.

## Caching

A cold `mise install` costs roughly a minute for a few tools. To cache it, mise's
data directory has to move inside the project, because GitLab only caches paths
under `$CI_PROJECT_DIR`:

```yaml
variables:
  MISE_DATA_DIR: $CI_PROJECT_DIR/.mise
before_script:
  - export PATH="$MISE_DATA_DIR/shims:$PATH"
  - mise install
cache:
  key:
    files: [mise.toml]
  paths: [.mise]
```

The `export` is needed because moving `MISE_DATA_DIR` also moves the shims, away
from the path the image put on `PATH`.

## Package managers

nub is deliberately not installed here. Its shims would compete with mise's for
`npm`/`yarn`/`pnpm`, and a project pinning `pnpm` in `mise.toml` could silently
get a different version. Pin package managers in `mise.toml`, or add
`nub = "latest"` to it if you want nub to resolve them from `package.json`'s
`packageManager` field instead.

## Not for PHP

mise builds PHP from source and installs extensions one at a time through
`pecl`, so a job would spend minutes compiling what
[`keepsuit/gitlab-ci-php`](../php/README.md) already has ready. Use the PHP image
for PHP.

## Building locally

```bash
docker build -t gitlab-ci-auto:local images/auto
```

| Build arg        | Default  |
| ---------------- | -------- |
| `DEBIAN_VERSION` | `trixie` |
