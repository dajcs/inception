
Now, let's tackle **WordPress**.

This is the most complex container because:
1.  It handles the PHP code (PHP-FPM).
2.  It needs to talk to the MariaDB container to store data.
3.  We have to install WordPress **automatically** using the command line (we cannot use the web browser installation wizard).

---

### 1. Directory Structure

Create the folders:

```bash
mkdir -p srcs/requirements/wordpress/conf
mkdir -p srcs/requirements/wordpress/tools
```

---

### 2. The Dockerfile (`srcs/requirements/wordpress/Dockerfile`)

We need PHP, the PHP extensions for MySQL, and `wget` to download the WordPress CLI tool.

```dockerfile
FROM debian:bullseye

# 1. Update and install PHP dependencies
# php-fpm: The PHP FastCGI Process Manager
# php-mysql: Allows PHP to talk to MariaDB
# mariadb-client: Useful if we need to test database connection from here
# wget: To download the WP-CLI
RUN apt-get update && apt-get install -y \
    wget \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    mariadb-client

# 2. Download WP-CLI (Command Line Interface for WordPress)
# This allows us to install WordPress using commands instead of the browser.
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# 3. Make it executable and move it to a global path
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# 4. Copy custom PHP configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# 5. Create the folder where PHP-FPM needs to run its socket file (otherwise it might crash)
RUN mkdir -p /run/php

# 6. Copy the startup script
COPY tools/create_wordpress.sh /usr/local/bin/create_wordpress.sh
RUN chmod +x /usr/local/bin/create_wordpress.sh

# 7. Set the working directory
WORKDIR /var/www/html

# 8. Expose port 9000 (PHP-FPM default)
EXPOSE 9000

# 9. Start the script
ENTRYPOINT ["/usr/local/bin/create_wordpress.sh"]
```

---

### 3. The Configuration File (`srcs/requirements/wordpress/conf/www.conf`)

By default, PHP-FPM listens on a "socket" file. This works if NGINX and PHP are on the same machine. But here, they are in different containers. We need PHP to listen on a **Network Port (9000)** so NGINX can reach it.

```ini
[www]

; Unix user/group of processes
user = www-data
group = www-data

; The address on which to accept FastCGI requests.
; We change this from a socket file to port 9000.
listen = 9000

; Access permissions
listen.owner = www-data
listen.group = www-data
```

---

### 4. The Startup Script (`srcs/requirements/wordpress/tools/create_wordpress.sh`)

This script does the magic. It checks if WordPress is installed. If not, it downloads it and sets up the users based on Environment Variables.

**Note:** The variables (like `$SQL_DATABASE`, `$WP_ADMIN_USER`, etc.) will come from the `.env` file we will create in the next step.

```bash
#!/bin/bash

# Check if wp-config.php exists. If not, we install WordPress.
if [ -f ./wp-config.php ]
then
	echo "WordPress already installed"
else
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
```

---

### 5. Check your progress

Run the build command for WordPress:

```bash
docker build -t wordpress_test ./requirements/wordpress
```

If this passes, you have successfully built all three "recipes" (Dockerfiles). The next step is the big one: **Orchestration with Docker Compose**. This is where we will create the `.env` file and tie everything together.
