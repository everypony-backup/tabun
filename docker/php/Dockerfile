FROM php:7.4-fpm

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN buildDeps='unzip' \
    && apt-get update && apt-get install -y $buildDeps git libonig-dev libcurl4-openssl-dev imagemagick libmagickwand-dev libmagickcore-dev \
    && pecl install imagick redis && docker-php-ext-enable imagick redis \
    && docker-php-ext-install mysqli gettext json curl bcmath mbstring \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.17 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge -y --auto-remove $buildDeps \
    && docker-php-source delete

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /app
CMD ["php-fpm"]
