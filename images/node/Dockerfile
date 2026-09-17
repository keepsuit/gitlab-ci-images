# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie
ARG NODE_VERSION=24
ARG NUB_VERSION=latest


FROM debian:${DEBIAN_VERSION}-slim
ARG NODE_VERSION
ENV DEBIAN_FRONTEND=noninteractive

# gnupg is only needed by the setup script, so it is purged in the same layer.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get purge -y gnupg \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    git \
    nodejs \
    sudo \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ARG NUB_VERSION
RUN npm install -g @nubjs/nub@${NUB_VERSION} \
    && npm cache clean --force

# Keep existing pipelines that call `corepack enable` from failing.
COPY --chmod=755 shared/corepack.sh /usr/local/bin/corepack

RUN groupadd -r user \
    && useradd -r -g user -G audio,video,sudo user \
    && mkdir -p /home/user \
    && mkdir -p /builds \
    && chown -R user:user /home/user \
    && chown -R user:user /builds \
    && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

# nub writes its shims under the XDG data directory, so this runs as `user`,
# not root. Setting PATH explicitly is what makes them work: `nub pm shim`
# otherwise relies on editing .profile, which a non-interactive CI shell never
# sources.
ENV PATH=/home/user/.local/share/nub/shims:${PATH}
RUN nub pm shim \
    && cd /home/user/.local/share/nub/shims \
    && for f in npx pnpm pnpx yarn yarnpkg; do ln -f npm "$f"; done \
    && test -x /home/user/.local/share/nub/shims/pnpm

CMD ["bash"]
