# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 15:47:41 by anemet            #+#    #+#              #
#    Updated: 2026/01/20 13:50:23 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
    mariadb-client \
    php7.4-redis

# 2. Download WP-CLI (Command Line Interface for WordPress)
# This allows us to install WordPress using commands instead of the browser
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# 3. Make it executable and move it to a global path
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# 4. Copy custom PHP configuration
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# 5. Create the folder where PHP-FPM needs to run its 
#                           socket file (otherwise it might crash)
RUN mkdir -p /run/php

# 6. Copy and set executable the startup script
COPY tools/create_wordpress.sh /usr/local/bin/create_wordpress.sh
RUN chmod +x /usr/local/bin/create_wordpress.sh

# 7. Set the working directory
WORKDIR /var/www/html

# 8. Expose port 9000 (PHP-FPM default)
EXPOSE 9000

# 9. Start the script
ENTRYPOINT ["/usr/local/bin/create_wordpress.sh"]
