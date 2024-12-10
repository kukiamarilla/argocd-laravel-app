# Etapa 1: Construcción del Frontend
FROM node:20 AS frontend-builder

# Establece el directorio de trabajo
WORKDIR /app

# Copia solo los archivos relacionados con el frontend
COPY package*.json ./
COPY resources/js ./resources/js
COPY resources/css ./resources/css
COPY vite.config.js ./

# Instala dependencias y construye el frontend
RUN npm install && npm run build

# Etapa 2: Construcción de la aplicación Laravel con PHP-FPM
FROM php:8.2-fpm

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /var/www

# Instala extensiones y dependencias necesarias
RUN apt-get update && apt-get install -y \
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

# Copia los archivos del frontend generados en la primera etapa
COPY --from=frontend-builder /app/dist /var/www/public

# Copia los archivos de la aplicación Laravel al contenedor
COPY . /var/www

# Instala dependencias de Laravel
RUN composer install --optimize-autoloader --no-dev

# Configura permisos para las carpetas de almacenamiento y caché
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Exponer el puerto 9000 para PHP-FPM
EXPOSE 9000

# Inicia el servidor PHP-FPM
CMD ["php-fpm"]
