#!/bin/bash

# 1. Start MariaDB
service mariadb start

# 2. Wait for MariaDB to be ready
sleep 5

# 3. Configure DB if not exists
if [ -d "/var/lib/mysql/$SQL_DATABASE" ]
then
    echo "Database already exists"
else
    # Set up the database and user
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Set Root Password (this locks down the server)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    echo "MariaDB setup complete."
fi

# 4. Stop MariaDB nicely
# We use mysqladmin with the password variable to authenticate the shutdown command.
mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

# 5. Start the final process
exec mysqld_safe
