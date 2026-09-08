#!/bin/sh
# Installed as /usr/local/bin/corepack and replaced by nub in these images.
echo "warning: corepack is not used in this image, nub provides the npm/yarn/pnpm shims." >&2
echo "warning: ignored 'corepack $*'. See https://nubjs.com/docs/pm" >&2
exit 0
