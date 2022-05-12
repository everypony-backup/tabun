#!/usr/bin/env bash
# TODO: Ожидание SQL сервера, аля: while <isNotConnectedToSQL> do sleep 5; <connectSQL>; end;
# TODO: Миграции SQL
service nginx start
php-fpm