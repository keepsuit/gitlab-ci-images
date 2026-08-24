# syntax=docker/dockerfile:1

ARG BASE_IMAGE=keepsuit/gitlab-ci-php:8.4
FROM ${BASE_IMAGE}

# Install packages
RUN sudo apt-get update && sudo apt-get install -y \
    chromium \
    chromium-driver \
    && sudo rm -rf /var/lib/apt/lists/*

# Install puppeteer
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN sudo -E npm install --global --unsafe-perm puppeteer

# Install playwright dependencies
RUN sudo npx playwright install-deps
