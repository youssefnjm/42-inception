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
        --dbname=wordpress \
        --dbuser=wp_user \
        --dbpass=wp_pass \
        --dbhost=mariadb
else
    echo "wp-config.php file already exist";
fi

# Install WordPress if not already installed
if [! wp core is-installed --allow-root]; then
    echo "Installing WordPress..."
    wp core install --allow-root \
        --url="ynoujoum.42.fr" \
        --title="Inception" \
        --admin_user="boss" \
        --admin_password="boss_pass" \
        --admin_email="boss@42.fr" \
        --skip-email

    echo "Creating second user..."
    wp user create --allow-root \
        "editor" "editor@42.fr" \
        --user_pass="editor_pass" \
        --role=editor
else
    echo "wordpress is file already present";
fi

# Copy test PHP file and set files owner
cp /usr/local/bin/index.php /var/www/html/index.php 2>/dev/null || true
chown -R www-data:www-data /var/www/html

echo "🟢 Starting worldpress in foreground..."
exec "$@"