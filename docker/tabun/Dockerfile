FROM alpine:3.13 AS frontend

COPY . /frontend
COPY docker/frontend /frontend

WORKDIR /frontend

RUN apk add npm gettext git
RUN mkdir -p /frontend/static && sh /frontend/compile_locales.sh
RUN npm install


FROM frontend AS frontend-production
RUN npm run build
RUN git describe --always > /frontend/static/backend.version

#FROM frontend AS frontend-development
#RUN npm run build
#RUN npm run build-dev




FROM php:7.4-fpm AS backend

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
        unzip libzip-dev git \
        libonig-dev \
        libcurl4-openssl-dev \
        imagemagick libmagickwand-dev libmagickcore-dev \
        locales \
    && pecl install imagick redis xdebug && docker-php-ext-enable imagick redis xdebug \
    && docker-php-ext-install mysqli gettext json curl bcmath mbstring zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-source delete \
    && sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

COPY index.php	/app/index.php
COPY engine 	/app/engine
COPY classes	/app/classes
COPY settings	/app/settings
COPY templates	/app/templates

COPY docker/tabun /backend

WORKDIR /backend

RUN composer update && composer install --no-dev --no-interaction --optimize-autoloader && \
	composer clearcache && \
	cp -r /backend/vendor /app/vendor && \
	rm -rf /backend

WORKDIR /app

RUN mkdir -p /storage
RUN chown www-data:www-data /storage
	
CMD ["php-fpm"]

FROM backend AS production

COPY --from=frontend-production /frontend/static /static
COPY ./docker/tabun/tabun-dev.conf /usr/local/etc/php-fpm.d/www.conf

#FROM backend as development
#
#COPY --from=frontend-development /frontend/static /static
#COPY ./docker/tabun/tabun.conf /usr/local/etc/php-fpm.d/tabun.conf
#RUN composer install --no-dev --no-interaction --optimize-autoloader && \
#	composer clearcache && \#
#	cp -r /backend/vendor /app/vendor && \
#	rm -rf /backend
#
#WORKDIR /app
