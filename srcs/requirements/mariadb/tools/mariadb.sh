#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    mariadb.sh                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 14:50:22 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 14:50:23 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# handling the "Inception" requirement of creating the database/users automatically

# variables like ${SQL_DATABASE} are defined in the .env

set -e

# Start the MariaDB service temporarily to configure it
service mariadb start

# Wait 5 secs to start fully
sleep 5

# Check if the database works and if we need to set it up
if [ -d "/var/lib/mysql/$SQL_DATABASE" ]
then
    echo "Database already exists"
else
    # 1. Secure the installation (conceptually similar to mysql_secure_installation)
    # 2. Create the Database
    # 3. Create the User (for WordPress)
    # 4. Give the User permissions
    # 5. Set the Root password

    echo "Setting up MariaDB..."

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Reset root password  (this shuts down access without password)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    echo "MariaDB setup complete."
fi

# Stop the temporary service
service mariadb stop

# Start MariaDB in "safe mode" (foreground) so the container stays running
# We use exec so this process replaces the shell script as PID 1
exec mysqld_safe

