FROM alpine:3.13 AS frontend

WORKDIR /app
RUN apk add npm gettext

COPY package.json package.json
COPY package-lock.json package-lock.json

RUN npm install
RUN ls -la /usr/lib/node_modules
COPY . .
RUN sh ./docker/compile_locales.sh
RUN npx webpack -p --color --progress


FROM php:7.4-fpm AS dev

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        unzip libzip-dev git \
        libonig-dev \
        libcurl4-openssl-dev \
        imagemagick libmagickwand-dev libmagickcore-dev \
    && pecl install imagick redis xdebug && docker-php-ext-enable imagick redis xdebug \
    && docker-php-ext-install mysqli gettext json curl bcmath mbstring zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.17 \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-source delete

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /app

COPY ./docker/php/www-dev.conf /usr/local/etc/php-fpm.d/www.conf

CMD ["php-fpm"]


FROM dev AS prod
COPY . .
COPY ./docker/php/www-dev.conf /usr/local/etc/php-fpm.d/www.conf
RUN composer install --no-dev --no-interaction --optimize-autoloader \
    && composer clearcache \
    && chown -R www-data:www-data .
