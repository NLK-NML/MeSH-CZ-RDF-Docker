# Updated:   2026-02-06
# Build image:
# docker build -t skosmos-meshcz ./skosmos

FROM debian:stable-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ENV SKOSMOS_GIT=https://github.com/NatLibFi/Skosmos.git
ENV SKOSMOS_BRANCH=main

# ---- System dependencies ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    curl \
    ca-certificates \
    git \
    locales \
    php8.4 \
    libapache2-mod-php8.4 \
    php8.4-cli \
    php8.4-curl \
    php8.4-intl \
    php8.4-mbstring \
    php8.4-xsl \
    php8.4-zip \
    php8.4-apcu \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# ---- Get Apache modules ----
RUN a2enmod rewrite headers expires

# ---- Composer / PHP dependencies ----
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# ---- Clone Skosmos branch ----
RUN git clone -b ${SKOSMOS_BRANCH} ${SKOSMOS_GIT}

RUN cp -a Skosmos/. /var/www/html/

WORKDIR /var/www/html

# ---- Download Skosmos release ----
# RUN curl -sL https://github.com/NatLibFi/Skosmos/archive/refs/tags/v3.1.tar.gz | tar xz --strip-components=1

# Node / frontend dependencies
RUN npm install --omit=dev

# ---- Composer install (production-ready) ----
RUN composer install --no-dev --optimize-autoloader

# ---- Permissions ----
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# ---- Copy custom configuration ----
COPY config/skosmos-mesh.ttl /var/www/html/config.ttl
COPY config/mdv-skosmos-custom.css /var/www/html/resource/css/mdv-skosmos-custom.css
COPY config/skosmos-vhost.txt /etc/apache2/sites-available/000-default.conf

# ---- Expose Apache ----
EXPOSE 80

# ---- Start Apache ----
CMD ["apachectl", "-D", "FOREGROUND"]
