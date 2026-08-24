# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie


FROM debian:${DEBIAN_VERSION}-slim
ENV DEBIAN_FRONTEND=noninteractive

# mise repository.
# gnupg is only needed to dearmor the key, so it is purged in the same layer.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && install -dm 755 /etc/apt/keyrings \
    && curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor > /etc/apt/keyrings/mise-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" > /etc/apt/sources.list.d/mise.list \
    && apt-get purge -y gnupg \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    git \
    mise \
    sudo \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add non-privileged user
RUN groupadd -r user \
    && useradd -r -g user -G sudo user \
    && mkdir -p /home/user \
    && mkdir -p /builds \
    && chown -R user:user /home/user \
    && chown -R user:user /builds \
    && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Run everything after as non-privileged user.
USER user
WORKDIR /home/user

# mise puts tool shims here once `mise install` has run. Setting PATH up front
# is what makes them resolve: `mise activate` otherwise relies on a shell hook
# that a non-interactive CI shell never runs.
ENV PATH=/home/user/.local/share/mise/shims:${PATH}
# CI clones into /builds and nobody is there to answer a trust prompt.
ENV MISE_TRUSTED_CONFIG_PATHS=/builds
ENV MISE_YES=1

CMD ["bash"]
