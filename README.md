# gitlab-ci-images

Docker images for GitLab CI jobs (testing, asset building, deploys).

## Images

| Image                                              | Tags                                | For                                                                        |
| -------------------------------------------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| [`keepsuit/gitlab-ci-php`](images/php/README.md)   | `8.5`, `8.4`, `8.3` (+ `-browsers`) | PHP / Laravel test and asset jobs. Everything baked in.                    |
| [`keepsuit/gitlab-ci-auto`](images/auto/README.md) | `latest`                            | Node projects and deploy jobs. mise provisions the tools the project pins. |

Each image's README covers its usage, environment variables and build args.
Docker Hub: [gitlab-ci-php](https://hub.docker.com/r/keepsuit/gitlab-ci-php),
[gitlab-ci-auto](https://hub.docker.com/r/keepsuit/gitlab-ci-auto).

Pick `gitlab-ci-php` when the job needs PHP: it ships PHP and its extensions
prebuilt, ready at process start. Pick `gitlab-ci-auto` for everything else — it
ships almost nothing and lets `mise.toml` decide, which works well for tools
distributed as prebuilt binaries and badly for PHP.
