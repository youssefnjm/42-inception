#!/bin/bash

set -e
echo "🟢 Starting worldpress in foreground..."

mkdir -p /var/www/html

mkdir -p /run/php

# Copy test PHP file
cp /usr/local/bin/index.php /var/www/html/index.php 2>/dev/null || true

chown -R www-data:www-data /var/www/html

exec "$@"