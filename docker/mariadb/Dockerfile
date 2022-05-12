FROM mariadb:latest
WORKDIR /app
COPY ./fixtures fixtures
COPY ./docker docker
RUN ./docker/mariadb/copy_fixtures.sh
COPY ./docker/mariadb/conf.d /etc/mysql/conf.d
RUN ["/usr/local/bin/docker-entrypoint.sh"]