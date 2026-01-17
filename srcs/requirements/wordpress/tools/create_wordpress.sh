#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    create_wordpress.sh                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 16:11:50 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 16:11:51 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Check if wp-config.php exists. If not, we install WordPress.
if [ -f ./wp-config.php ]
then
    echo "WordPress already installed"
else
    # 0. Wait for MariaDB to be ready
    # We try to connect to the DB host. If it fails, we sleep and retry.
    echo "Waiting for MariaDB..."
    while ! mysqladmin ping -h"mariadb" --silent; do
        sleep 1
    done
    echo "MariaDB is up!"

    # 1. Download WordPress core files
    wp core download --allow-root

    # 2. Create the config file using env variables
    # We point DB_HOST to 'mariadb' (the name of the container)
    wp config create \
    --dbname=$SQL_DATABASE \
    --dbuser=$SQL_USER \
    --dbpass=$SQL_PASSWORD \
    --dbhost=mariadb:3306 --allow-root

    # 3. Install WordPress (This creates the Admin User)
    wp core install \
    --url=$DOMAIN_NAME \
    --title=$SITE_TITLE \
    --admin_user=$WP_ADMIN_USER \
    --admin_password=$WP_ADMIN_PASSWORD \
    --admin_email=$WP_ADMIN_EMAIL --allow-root

    # 4. Create a second user (Editor)
    wp user create \
    $WP_USER \
    $WP_EMAIL \
    --role=author \
    --user_pass=$WP_PASSWORD --allow-root
fi

# Start PHP-FPM in the foreground (-F)
exec /usr/sbin/php-fpm7.4 -F

