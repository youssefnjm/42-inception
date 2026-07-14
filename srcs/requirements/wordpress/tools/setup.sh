#!/bin/bash

set -e

mkdir -p /var/www/html
mkdir -p /run/php

echo "Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u wp_user -pwp_pass --silent; do
    echo "MariaDB not ready yet. Retrying..."
    sleep 1
done
echo "MariaDB is ready!"

# Download WordPress if not present
if [ ! -f wp-config.php ] && [ ! -f wp-config-sample.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
else
    echo "wordpress is file already present";
fi

# Create wp-config.php if not present
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$DB_HOST
else
    echo "wp-config.php file already exist";
fi

# Install WordPress if not already installed
if ! wp core is-installed --allow-root ; then
    echo "Installing WordPress..."
    wp core install --allow-root \
        --url="ynoujoum.42.fr" \
        --title="Inception" \
        --admin_user=$WP_ADMIN \
        --admin_password=$WP_ADMIN_EMAIL \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email

    echo "Creating second user..."
    wp user create --allow-root \
        $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASS \
        --role=editor
else
    echo "wordpress file already present";
fi

# Copy test PHP file and set files owner
cp /usr/local/bin/index.php /var/www/html/index.php 2>/dev/null || true
chown -R www-data:www-data /var/www/html

echo "🟢 Starting worldpress in foreground..."
exec "$@"