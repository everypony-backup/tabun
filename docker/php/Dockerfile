FROM php:7.4-fpm

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /app
CMD ["php-fpm"]
