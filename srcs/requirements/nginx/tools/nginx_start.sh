#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    nginx_start.sh                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 14:20:13 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 14:21:17 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Script is needed because we have to generate the SSL certificate
# inside the container before NGINX starts

# check if the certificate already exists
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Nginx: Setting up SSL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=anemet.42.fr/UID=anemet"
fi

# Start Nginx
# 'daemon off;' is crucial. Docker containers exit if the main process
# stops. By default, Nginx runs in the background. We force it to
# run in the foreground so the container stays alive
exec nginx -g 'daemon off;'