FROM mariadb:latest
ENV MARIADB_USER=tabun
ENV MARIADB_PASSWORD=tabun
ENV MARIADB_DATABASE=tabun
ENV MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=true
WORKDIR /app
COPY ./fixtures fixtures
COPY ./docker docker
RUN ./docker/mariadb/copy_fixtures.sh
# TODO: Починить кодировку при импорте миграций
RUN ["/usr/local/bin/docker-entrypoint.sh"]