# keepsuit/gitlab-ci-php

PHP CI image with everything baked in and ready at process start: PHP with the
common extensions, Composer, PIE, Node, nub, bun and git.

| Tags                                           | Contents                                                          |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| `8.5`, `8.4`, `8.3`                            | PHP (cli + common extensions), Composer, PIE, Node, nub, bun, git |
| `8.5-browsers`, `8.4-browsers`, `8.3-browsers` | the above + Chromium, Puppeteer, Playwright system deps           |

Legacy tags `cappuc/gitlab-ci-laravel:php8.4` and `cappuc/gitlab-ci-laravel:php8.4-browsers`
are still published from the same builds. Prefer the `keepsuit` names for new projects.

## Usage

```yaml
test:
  image: keepsuit/gitlab-ci-php:8.4
  variables:
    WITH_PCOV: 1
  script:
    - composer install
    - vendor/bin/pest --coverage
```

Use the `-browsers` tag for jobs that need a real browser (Dusk, Playwright,
Puppeteer). It adds Chromium and the Playwright system dependencies on top of
the same PHP image, so everything above applies unchanged.

## Environment variables

Handled by the entrypoint:

| Variable            | Effect                                             |
| ------------------- | -------------------------------------------------- |
| `WITH_XDEBUG`       | enables the xdebug extension (disabled by default) |
| `WITH_PCOV`         | enables the pcov extension (disabled by default)   |
| `COMPOSER_GITHUB`   | sets a global `github-oauth` token for composer    |
| `COMPOSER_GITLAB`   | sets a global `gitlab-token` for composer          |
| `COMPOSER_KEEPSUIT` | sets http-basic auth for `composer.keepsuit.com`   |

Both coverage extensions ship disabled because each one slows PHP down even when
idle. Enable the one the job actually needs.

The image runs as the non-root `user`, which has passwordless `sudo`.

## Package managers

[nub](https://github.com/nubjs/nub) replaces corepack, which was
[unbundled from Node in v25](https://github.com/nodejs/nodejs.org/issues/7555).
`nub pm shim` runs at build time, so `npm`, `yarn` and `pnpm` resolve to the
version the project pins in `packageManager` with no setup in the job. Projects
without a pin still work: nub infers the version from the committed lockfile and
warns.

`nub` itself is available too (`nub install`, `nub run build`, `nubx ...`).

`corepack` is stubbed with a script that prints a warning and exits 0, so a
`corepack enable` left in an existing pipeline does not fail the job. Remove
those calls when convenient.

## Building locally

```bash
docker build -f images/php/Dockerfile -t gitlab-ci-php:local \
  --build-arg PHP_VERSION=8.4 images
docker build -t gitlab-ci-php-browsers:local \
  --build-arg BASE_IMAGE=gitlab-ci-php:local \
  -f images/php/browsers.Dockerfile images/php
```

| Build arg        | Default                                              |
| ---------------- | ---------------------------------------------------- |
| `PHP_VERSION`    | `8.4`                                                |
| `NODE_VERSION`   | `24`                                                 |
| `NUB_VERSION`    | `latest`                                             |
| `DEBIAN_VERSION` | `trixie`                                             |
| `BASE_IMAGE`     | `keepsuit/gitlab-ci-php:8.4` (browsers variant only) |
