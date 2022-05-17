FROM mariadb:latest
WORKDIR /app
COPY ./fixtures fixtures
COPY ./docker docker
RUN ./docker/mariadb/copy_fixtures.sh
RUN ["/usr/local/bin/docker-entrypoint.sh"]