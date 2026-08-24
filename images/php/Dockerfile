# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=trixie
ARG NODE_VERSION=24
ARG PHP_VERSION=8.4
ARG NUB_VERSION=latest


FROM debian:${DEBIAN_VERSION}-slim
ARG DEBIAN_VERSION
ARG NODE_VERSION
ARG PHP_VERSION
ENV DEBIAN_FRONTEND=noninteractive
ENV PHP_INI_DIR=/etc/php/${PHP_VERSION}/cli

# Configure the node and php apt repositories.
# gnupg is only needed by the nodesource setup script, so it is purged in the
# same layer to keep it out of the image.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/php.list \
    && apt-get purge -y gnupg \
    && apt-get autoremove -y \
    && rm -f /tmp/debsuryorg-archive-keyring.deb \
    && rm -rf /var/lib/apt/lists/*

# Install packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    git \
    nodejs \
    sudo \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install php & extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-gettext \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-pcov \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-protobuf \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-yaml \
    php${PHP_VERSION}-zip \
    && rm -rf /var/lib/apt/lists/* \
    && phpdismod pcov \
    && phpdismod xdebug

# Install pie & grpc, then drop the installer
RUN ln -s $(php -r 'echo ini_get("extension_dir");') /usr/lib/extensions \
    && curl -sSfL https://github.com/php/pie/releases/latest/download/pie.phar -o /usr/local/bin/pie \
    && chmod +x /usr/local/bin/pie \
    && pie install -n bsn4/grpc \
    && rm -rf /root/.cache /tmp/*

# Install nub, which provides the npm/yarn/pnpm shims in place of corepack.
ARG NUB_VERSION
RUN npm install -g @nubjs/nub@${NUB_VERSION} \
    && npm cache clean --force

# Shadow the corepack Node still bundles, so pipelines that call `corepack
# enable` warn instead of failing the job.
COPY --chmod=755 corepack.sh /usr/local/bin/corepack

# Install composer
COPY --from=composer/composer:2-bin /composer /usr/local/bin/composer

# Install bun
COPY --from=oven/bun:1 /usr/local/bin/bun /usr/local/bin/bun

COPY conf.d $PHP_INI_DIR/conf.d

# Add non-privileged user
RUN groupadd -r user \
    && useradd -r -g user -G audio,video,sudo user \
    && mkdir -p /home/user \
    && mkdir -p /builds \
    && chown -R user:user /home/user \
    && chown -R user:user /builds \
    && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Run everything after as non-privileged user.
USER user
WORKDIR /home/user

# nub writes its shims here (per-user, XDG), so this has to run as `user` and
# not as root. Setting PATH explicitly is what makes the shims work: `nub pm
# shim` otherwise relies on editing .bashrc, which a non-interactive CI shell
# never sources.
ENV PATH=/home/user/.local/share/nub/shims:${PATH}
RUN nub pm shim

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
