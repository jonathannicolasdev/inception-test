#!/bin/sh

# Function to check if MariaDB is running
wait_for_mariadb() {
    while ! mysqladmin ping --silent; do
        echo "Waiting for MariaDB to be available..."
        sleep 2
    done
}

# Start MariaDB service
/etc/init.d/mariadb start

# Wait for MariaDB to fully start
wait_for_mariadb

# Check if the database already exists
DB_EXISTS=$(echo "SHOW DATABASES LIKE '$MYSQL_DATABASE';" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD" | grep "$MYSQL_DATABASE")

if [ -z "$DB_EXISTS" ]; then
    # Create the database if it doesn't exist
    echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD"

    # Create the user with the specified password
    echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD"

    # Grant all privileges to the root user from any host
    echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD"

    # Grant all privileges on the specified database to the new user
    echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD"

    # Flush privileges to ensure all changes take effect
    echo "FLUSH PRIVILEGES;" | mysql -uroot -p"$MYSQL_ROOT_PASSWORD"
fi

# Shut down MariaDB to prepare for safe start
mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown

# Start MariaDB safely
exec mariadbd-safe
