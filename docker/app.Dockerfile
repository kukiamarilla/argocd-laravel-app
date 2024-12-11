FROM php:8.2-fpm

WORKDIR /var/www

# Instala las dependencias necesarias
RUN apt-get update && apt-get install -y \
    nginx \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install \
    intl \
    mbstring \
    zip \
    pdo_mysql \
    opcache \
    && docker-php-ext-enable opcache

# Instala Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copia los archivos de Laravel
COPY . /var/www

# Instala las dependencias de Laravel
RUN composer install --optimize-autoloader --no-dev

# Configura permisos
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Copia la configuración de Nginx
COPY ./nginx.conf /etc/nginx/sites-available/default

# Exponer puerto 80
EXPOSE 80

# Configura un script de entrada para iniciar PHP-FPM y Nginx
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]