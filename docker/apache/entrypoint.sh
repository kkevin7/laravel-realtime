#!/bin/sh
set -e

composer install
npm install
npm run build
php artisan migrate --seed
chown -R www-data:www-data storage bootstrap/cache
chmod -R 777 storage bootstrap/cache
service supervisor start
supervisorctl reread
supervisorctl update
supervisorctl start chat-websockets:*

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apachectl -D FOREGROUND "$@"
fi

exec "$@"
