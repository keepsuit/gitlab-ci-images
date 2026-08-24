#!/bin/sh
# Installed as /usr/local/bin/corepack, shadowing the one Node still bundles.
# Corepack was unbundled from Node in v25 and is replaced by nub in this image;
# this stub keeps `corepack enable` in existing pipelines from failing the job.
echo "warning: corepack is not used in this image, nub provides the npm/yarn/pnpm shims." >&2
echo "warning: ignored 'corepack $*'. See https://nubjs.com/docs/pm" >&2
exit 0
