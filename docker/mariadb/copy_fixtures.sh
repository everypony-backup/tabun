#!/bin/sh

for file in $(ls /app/fixtures/migrations);
do
	cp "/app/fixtures/migrations/$file" "/docker-entrypoint-initdb.d/0100-$file"
done

for file in $(ls /app/fixtures/data);
do
	cp "/app/fixtures/data/$file" "/docker-entrypoint-initdb.d/0200-$file"
done