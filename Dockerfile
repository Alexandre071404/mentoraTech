FROM composer:2.8.12 AS builder
WORKDIR /app
COPY composer.json /app
RUN composer install --no-interaction --no-dev --optimize-autoloader


FROM php:8.3-cli-alpine
WORKDIR /app
COPY . /app
COPY --from=builder /app/vendor /app/vendor
CMD ["php", "Calculator.php"]
