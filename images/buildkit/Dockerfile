# syntax=docker/dockerfile:1

FROM moby/buildkit:v0.34.2 AS root
RUN apk add --no-cache aws-cli jq moreutils

FROM moby/buildkit:v0.34.2-rootless AS rootless
USER root
RUN apk add --no-cache aws-cli jq moreutils
USER 1000:1000
