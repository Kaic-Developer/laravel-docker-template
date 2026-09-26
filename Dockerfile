FROM php:8.4-fpm

# Diretório onde o Laravel ficará dentro do container
WORKDIR /var/www/html

# Dependências do sistema necessárias para PHP/Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    && docker-php-ext-install \
        pdo_mysql \
        zip \
        intl \
        bcmath \
        gd \
        pcntl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Confirma versões durante o build
RUN php -v && composer --version

CMD ["php-fpm"]