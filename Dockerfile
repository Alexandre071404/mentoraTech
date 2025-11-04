# --- Étape 1 : Construction de l'image PHP-FPM (pour exécuter le code PHP) ---
FROM php:8.3-fpm-alpine AS base

# Installation des dépendances système nécessaires pour PHP
# et des extensions courantes (pdo, mysqli, gd, zip, etc.)
RUN apk update && apk add --no-cache \
    autoconf \
    build-base \
    git \
    $([ $(php -r 'echo (int)(version_compare(PHP_VERSION, "8.0", ">="));') -eq 1 ] && echo 'oniguruma-dev' || echo 'libressl-dev') \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    mariadb-client \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql opcache \
    && docker-php-ext-configure gd --with-webp --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/cache/apk/*

# Installation de Composer
COPY --from=composer/composer:latest /usr/bin/composer /usr/local/bin/composer

# Définition du répertoire de travail à l'intérieur du conteneur
WORKDIR /var/www/html

# Le binaire PHP-FPM est exécuté par défaut par l'image parent

# --- Étape 2 : Construction de l'image finale (avec le code de l'application) ---
FROM base AS final

# Copie des fichiers de l'application
# Assurez-vous que votre application est dans le même répertoire que le Dockerfile
COPY . /var/www/html

# Exécution de Composer pour installer les dépendances (si elles existent)
RUN composer install --no-dev --optimize-autoloader

# Correction des permissions
RUN chown -R www-data:www-data /var/www/html
