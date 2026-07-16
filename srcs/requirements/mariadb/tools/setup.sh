#!/bin/bash 

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Check if already initialized 
if [ ! -d /var/lib/mysql/mysql ]; then
    echo "🟡 First run: initializing MariaDB..."

    # Create system tables 
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    # Start server temporarily in background 
    mysqld --user=mysql --datadir=/var/lib/mysql &

    # Wait until server is ready 
    echo "🟡 Waiting for MariaDB to start..."
    until mysqladmin ping --silent; do
        echo "🟡 MariaDB not ready yet. Retrying..."
        sleep 1
    done
    echo "🟡 MariaDB is ready!"

    # Create database and users 
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
    mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO '$MYSQL_USER'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"

    echo "🟡 Database and users created."

    # Stop temporary server 
    kill $!
fi

# Start server in foreground as PID 1 
echo "🟢 Starting MariaDB in foreground..."
exec mysqld --user=mysql