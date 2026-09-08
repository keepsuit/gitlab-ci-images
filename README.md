# gitlab-ci-images

Docker images for GitLab CI jobs (testing, asset building, deploys).

## Images

| Image                                              | Tags                                | For                                                                        |
| -------------------------------------------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| [`keepsuit/gitlab-ci-php`](images/php/README.md)   | `8.5`, `8.4`, `8.3` (+ `-browsers`) | PHP / Laravel test and asset jobs. Everything baked in.                    |
| [`keepsuit/gitlab-ci-node`](images/node/README.md) | `24`, `26`                          | Node projects. Node and nub are ready at process start.                    |
| [`keepsuit/gitlab-ci-auto`](images/auto/README.md) | `latest`                            | Deploy jobs and projects that need mise-managed tools.                    |

Each image's README covers its usage, environment variables and build args.
Docker Hub: [gitlab-ci-php](https://hub.docker.com/r/keepsuit/gitlab-ci-php),
[gitlab-ci-node](https://hub.docker.com/r/keepsuit/gitlab-ci-node),
[gitlab-ci-auto](https://hub.docker.com/r/keepsuit/gitlab-ci-auto).

Pick `gitlab-ci-php` when the job needs PHP: it ships PHP and its extensions
prebuilt, ready at process start. Pick `gitlab-ci-node` for Node projects that
want a fixed LTS runtime and package-manager shims. Pick `gitlab-ci-auto` for everything else — it
ships almost nothing and lets `mise.toml` decide, which works well for tools
distributed as prebuilt binaries and badly for PHP.
