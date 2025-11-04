FROM composer:2.8.12 AS builder
WORKDIR /app
COPY . /app
RUN composer install --no-interaction --no-dev --optimize-autoloader


FROM php:8.3-cli-alpine
WORKDIR /app
COPY --from=builder /app /app
CMD ["php", "Calculator.php"]
