#!/bin/bash

# 1. host configuration
#########################

# Open `/etc/hosts` on your machine.
# Add the line: `127.0.0.1 login.42.fr` 
# (replace `login` with your 42 username)

# create the persistent storage folders on host
mkdir -p /home/anemet/data/mariadb
mkdir -p /home/anemet/data/wordpress


# 2. Project directory structure
#################################

touch Makefile
touch README.md
touch USER_DOC.md
touch DEV_DOC.md

mkdir secrets/
touch secrets/db_password.txt
touch secrets/db_root_password.txt
touch secrets/wp_admin_password.txt

mkdir srcs/
touch srcs/ .env
touch srcs/ docker-compose.yml

mkdir srcs/requirements/

mkdir srcs/requirements/mariadb/
mkdir srcs/requirements/mariadb/conf/
touch srcs/requirements/mariadb/conf/50-server.cnf
mkdir srcs/requirements/mariadb/tools/
touch srcs/requirements/mariadb/tools/mariadb.sh
touch srcs/requirements/mariadb/Dockerfile

mkdir srcs/requirements/nginx/
mkdir srcs/requirements/nginx/conf/
touch srcs/requirements/nginx/conf/nginx.conf
mkdir srcs/requirements/nginx/tools/
touch srcs/requirements/nginx/tools/nginx_start.sh
touch srcs/requirements/nginx/Dockerfile

mkdir srcs/requirements/wordpress/
mkdir srcs/requirements/wordpress/conf/
touch srcs/requirements/wordpress/conf/www.conf
mkdir srcs/requirements/wordpress/tools/
touch srcs/requirements/wordpress/tools/create_wordpress.sh
touch srcs/requirements/wordpress/Dockerfile
