# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 17:08:25 by anemet            #+#    #+#              #
#    Updated: 2026/01/20 18:22:47 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

name = inception

all:
	@printf "Launch configuration ${name}...\n"
	@bash srcs/named_vols.sh
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d

build:
	@printf "Building configuration ${name}...\n"
	@bash srcs/named_vols.sh
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker compose -f ./srcs/docker-compose.yml down

re: down
	@printf "Rebuild configuration ${name}...\n"
	@docker compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a

fclean:
	@printf "Total clean of all configurations docker\n"
	# Stop containers AND remove docker-managed volumes (like portainer_data)
	@docker compose -f ./srcs/docker-compose.yml down --volumes
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@printf "Wipe /home/anemet/data with debian container\n"
	@docker run --rm -v /home/anemet/data:/data debian:bullseye bash -c "rm -rf /data/mariadb/* /data/wordpress/*"
	@printf "Removing debian:bullseye image\n"
	@docker rmi debian:bullseye >/dev/null 2>&1 || true


.PHONY	: all build down re clean fclean
