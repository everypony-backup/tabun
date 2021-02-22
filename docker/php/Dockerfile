FROM php:7.4-fpm AS base

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        unzip libzip-dev git \
        libonig-dev \
        libcurl4-openssl-dev \
        imagemagick libmagickwand-dev libmagickcore-dev \
        gettext \
    && pecl install imagick redis && docker-php-ext-enable imagick redis \
    && docker-php-ext-install mysqli gettext json curl bcmath mbstring zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.17 \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-source delete

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /app

CMD ["php-fpm"]


FROM base AS dev
COPY . .
RUN composer install --no-dev --no-interaction --optimize-autoloader \
    && composer clearcache \
    && chown -R www-data:www-data .
