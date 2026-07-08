#!/bin/bash 
set -e

# Create required runtime directories
mkdir -p /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

# Check if already initialized 

    # Start server temporarily in background 
    mysqld --user=mysql --datadir=/var/lib/mysql &

    # Wait until server is ready 
    echo "Waiting for MariaDB to start..."
    until mysqladmin ping --silent; do
        sleep 1
    done
    echo "MariaDB is ready!"

    # Create database and users 
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    mysql -u root -e "CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'wp_pass';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    echo "Database and users created."

    # Stop temporary server 
    kill $!
    wait $!
fi

# Start server in foreground as PID 1 
echo "🟢 Starting MariaDB in foreground..."
exec mysqld --user=mysql