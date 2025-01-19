# Use PHP-FPM base image
FROM php:8.2-fpm

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libcurl4-openssl-dev libzip-dev libexif-dev libicu-dev libmagic-dev \
    libonig-dev libxml2-dev \
    libldap2-dev libldap-common libsasl2-dev \
    imagemagick libmagickwand-dev \
    unzip git curl cron \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install imagick \
    && pecl install apcu \
    && docker-php-ext-enable imagick apcu \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        gd \
        zip \
        exif \
        intl \
        mbstring \
        ldap \
        opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Download and extract HumHub 1.16.2
RUN curl -L https://github.com/humhub/humhub/archive/refs/tags/v1.16.2.zip -o humhub.zip \
    && unzip humhub.zip \
    && cp -a humhub-1.16.2/. /var/www/html/ \
    && rm -rf humhub.zip humhub-1.16.2 \
    && composer install --no-dev --no-progress --no-interaction \
    && composer require humhub/gallery

# Configure PHP
RUN { \
    echo 'upload_max_filesize = 64M'; \
    echo 'post_max_size = 64M'; \
    echo 'max_execution_time = 300'; \
    echo 'memory_limit = 512M'; \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.max_accelerated_files=20000'; \
} > /usr/local/etc/php/conf.d/humhub.ini

# Set up permissions and directories
RUN mkdir -p \
    /var/www/html/protected/runtime/cache \
    /var/www/html/protected/runtime/session \
    /var/www/html/uploads \
    /var/www/html/assets \
    /var/www/html/protected/modules \
    /var/www/html/protected/runtime/searchdb \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod -R 775 /var/www/html/protected/runtime \
    /var/www/html/protected/config \
    /var/www/html/protected/modules \
    /var/www/html/uploads \
    /var/www/html/assets

# Add custom logo
COPY assets/logo.png /var/www/html/themes/HumHub/img/logo.png
COPY assets/logo-login.png /var/www/html/themes/HumHub/img/logo-login.png

# Add custom CSS
COPY assets/custom.css /var/www/html/themes/HumHub/css/custom.css

EXPOSE 9000

CMD ["php-fpm"]

