# Updated:   2026-01-25
# Build image:
# docker build -t meshcz-skosmos ./skosmos

FROM debian:stable-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

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
    unzip \
 && rm -rf /var/lib/apt/lists/*

# ---- Get Apache modules ----
RUN a2enmod rewrite headers expires

# ---- Composer / PHP dependencies ----
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# ---- Download Skosmos release ----
WORKDIR /var/www/html
RUN curl -sL https://github.com/NatLibFi/Skosmos/archive/refs/tags/v3.0.tar.gz | tar xz --strip-components=1

# Node / frontend dependencies
RUN npm install --omit=dev

# ---- Composer install (production-ready) ----
RUN composer install --no-dev --optimize-autoloader

# ---- Permissions ----
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# ---- Copy custom configuration ----
COPY config/skosmos-meshcz.ttl /var/www/html/config.ttl

COPY config/mdv-skosmos-custom.css /var/www/html/resource/css/xxx-mdv-skosmos-custom.css

COPY config/skosmos-vhost.txt /etc/apache2/sites-available/000-default.conf

# ---- Expose Apache ----
EXPOSE 80

# ---- Start Apache ----
CMD ["apachectl", "-D", "FOREGROUND"]
