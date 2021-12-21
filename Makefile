run: backend-version composer-install compile-locales
	docker-compose up

composer-install:
	docker-compose run --rm php-fpm composer install --no-interaction --optimize-autoloader

backend-version:
	@git describe --always > ./backend.version

compile-locales:
	docker-compose run --rm frontend sh ./docker/compile_locales.sh
	docker-compose restart php-fpm || true # ignore error if php-fpm container is not started
