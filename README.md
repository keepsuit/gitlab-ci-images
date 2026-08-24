# gitlab-ci-images

Docker images for GitLab CI jobs (testing, asset building).

## Images

PHP images are published to [`keepsuit/gitlab-ci-php`](https://hub.docker.com/r/keepsuit/gitlab-ci-php); the browsers variant is a tag suffix, not a separate repo.

| Tags | Contents |
| --- | --- |
| `8.5`, `8.4`, `8.3` | PHP (cli + common extensions), Composer, PIE, Node, yarn/pnpm (corepack), bun, git |
| `8.5-browsers`, `8.4-browsers`, `8.3-browsers` | the above + Chromium, Puppeteer, Playwright system deps |

Legacy tags `cappuc/gitlab-ci-laravel:php8.4` and `cappuc/gitlab-ci-laravel:php8.4-browsers`
are still published from the same builds. Prefer the `keepsuit/*` names for new projects.

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

### Environment variables

Handled by the entrypoint:

| Variable | Effect |
| --- | --- |
| `WITH_XDEBUG` | enables the xdebug extension (disabled by default) |
| `WITH_PCOV` | enables the pcov extension (disabled by default) |
| `COMPOSER_GITHUB` | sets a global `github-oauth` token for composer |
| `COMPOSER_GITLAB` | sets a global `gitlab-token` for composer |
| `COMPOSER_KEEPSUIT` | sets http-basic auth for `composer.keepsuit.com` |

Images run as the non-root `user`, which has passwordless `sudo`.

## Repository layout

```
images/
  php/
    Dockerfile           # keepsuit/gitlab-ci-php
    browsers.Dockerfile  # keepsuit/gitlab-ci-php:<v>-browsers, built FROM the above
    entrypoint.sh
    conf.d/              # php ini overrides
```

One directory per image family, shared as the build context; variants of a family
live in the same directory as `<variant>.Dockerfile`.

### Adding an image

1. Create `images/<family>/` with a `Dockerfile`, or add
   `images/<family>/<variant>.Dockerfile` to an existing family.
2. Add a job to `.github/workflows/build.yml` (copy the `php` job, change
   `context`/`file`, `cache` scope and `tags`). New images get a `keepsuit/*` tag
   only — the `cappuc/gitlab-ci-laravel` tags exist solely for `php` and
   `php-browsers`.

### Building locally

```bash
docker build -t gitlab-ci-php:local --build-arg PHP_VERSION=8.4 images/php
docker build -t gitlab-ci-php-browsers:local --build-arg BASE_IMAGE=gitlab-ci-php:local -f images/php/browsers.Dockerfile images/php
```

Images are built and pushed for `linux/amd64` and `linux/arm64` on every push to
`main`, weekly on Sunday, and on manual dispatch.
