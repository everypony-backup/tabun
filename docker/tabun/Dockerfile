FROM alpine:3.13 AS frontend
WORKDIR /app
COPY . /app
RUN apk add npm gettext
RUN mkdir -p /app/static && sh /app/docker/frontend/compile_locales.sh
RUN npm install && npm run build



FROM php:7.4-fpm AS backend
#
# Установка пакетов
#
# TODO: Убрать лишние пакеты
RUN apt-get update \
  && apt-get install -y \
  unzip \
  libzip-dev \
  git \
  libonig-dev \
  libcurl4-openssl-dev \
  imagemagick \
  libmagickwand-dev \
  libmagickcore-dev \
  locales \
  nginx \
  && pecl install imagick redis xdebug \
  && docker-php-ext-enable imagick redis xdebug \
  && docker-php-ext-install mysqli gettext json curl bcmath mbstring zip \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-source delete \
#
# Установка времени
#
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#
# Установка языка
#
RUN sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
#
# Копирование Backend'а в контейнер
#
WORKDIR /app
RUN chown -R www-data:www-data /app
COPY ./index.php /app/index.php
COPY ./engine /app/engine
COPY ./classes /app/classes
COPY ./settings /app/settings
COPY ./templates /app/templates
#
# Установка зависимостей Backend'а
#
WORKDIR /backend
COPY ./composer.json /backend/composer.json
RUN composer update \
  && composer install --no-dev --no-interaction --optimize-autoloader \
  && composer clearcache \
  && cp -r /backend/vendor /app/vendor \
  && rm -rf /backend
#
# Получение версии Backend'а
#
WORKDIR /app
COPY ./.git /app/.git
RUN git describe --always > /app/backend.version \
  && rm -rf /app/.git
#
# Создание папки для файлов пользователей
#
RUN mkdir /storage && chown www-data:www-data /storage
VOLUME ["/storage"]
#
# Настройка Nginx и PHP
#
COPY ./docker/tabun/nginx.conf /etc/nginx/sites-enabled/default
COPY ./docker/tabun/tabun-dev.conf /usr/local/etc/php-fpm.d/www.conf
#
# Автозапуск скрипта
#
COPY ./docker/tabun/entrypoint.sh /etc/entrypoint.sh
ENTRYPOINT /etc/entrypoint.sh



FROM backend AS application
COPY --from=frontend /app/static /app/static



FROM frontend AS frontend-dev
ENTRYPOINT npm run build-dev
