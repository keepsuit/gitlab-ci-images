# syntax=docker/dockerfile:1

ARG BASE_IMAGE=keepsuit/gitlab-ci-php:8.4
FROM ${BASE_IMAGE}

# Recommends are kept on purpose here: chromium's recommended fonts are what
# stop headless screenshots from rendering tofu boxes.
RUN sudo apt-get update && sudo apt-get install -y \
    chromium \
    chromium-driver \
    && sudo rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN sudo -E npm install --global --unsafe-perm puppeteer \
    && sudo npm cache clean --force

RUN sudo npx --yes playwright install-deps \
    && sudo rm -rf /var/lib/apt/lists/* /root/.npm ~/.npm
