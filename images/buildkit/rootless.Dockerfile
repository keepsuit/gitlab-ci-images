# syntax=docker/dockerfile:1

FROM moby/buildkit:v0.35.1-rootless
USER root
RUN apk add --no-cache aws-cli jq moreutils
USER 1000:1000
