#!/bin/bash
mkdir -p /run/php

mkdir -p /var/www/html

cd /var/www/html

rm -rf *

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 
chmod +x wp-cli.phar 
mv wp-cli.phar /usr/local/bin/wp

wp core download --allow-root

mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i -r "s/database_name_here/$MYSQL_DATABASE/1" wp-config.php
sed -i -r "s/username_here/$MYSQL_USER/1" wp-config.php
sed -i -r "s/password_here/$MYSQL_PASSWORD/1" wp-config.php
sed -i -r "s/localhost/mariadb/1" wp-config.php

wp core install --url=$DOMAIN_NAME --title="$WP_TITLE" --admin_user=$WP_ADMIN_USR --admin_password=$WP_ADMIN_PWD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

wp user create $WP_USR $WP_EMAIL --role=author --user_pass=$WP_PWD --allow-root

wp theme install astra --activate --allow-root

sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 9000/g' /etc/php/7.3/fpm/pool.d/www.conf
mkdir /run/php


# Start PHP-FPM service in the foreground
/usr/sbin/php-fpm7.3 -F &

# Start Nginx to serve the site
service nginx start

# Keep the container running
tail -f /dev/null