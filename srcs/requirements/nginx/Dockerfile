# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 14:00:35 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 14:00:38 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Use the penultimate stable version of Debian (Debian 11 Bullseye)
FROM debian:bullseye

# 1. Update package manager and install NGINX and OpenSSL
# -y means "yes" to prompts
RUN apt-get update && apt-get install -y nginx openssl

# 2. Create a folder to store the SSL certificate and key
RUN mkdir -p /etc/nginx/ssl

# 3. Copy our configuration file to the container
# We copy it to conf.d so NGINX reads it automatically
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# 4. Copy the startup script
COPY ./tools/nginx_start.sh /var/www/nginx_start.sh

# 5. Give execution rights to the script
RUN chmod +x /var/www/nginx_start.sh

# 6. Define the command that runs when the container starts
ENTRYPOINT ["/var/www/nginx_start.sh"]
