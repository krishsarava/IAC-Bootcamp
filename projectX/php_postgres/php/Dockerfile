FROM php:8.2-fpm

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

CMD ["php-fpm"]
