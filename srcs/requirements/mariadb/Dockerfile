# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 14:39:20 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 14:43:33 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get install -y mariadb-server

# Copy the configuration file to the correct location in the container
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the startup script
COPY tools/mariadb.sh /mariadb.sh

# Make the script executable
RUN chmod +x /mariadb.sh

# Expose port 3306 (standard MySQL port)
EXPOSE 3306

# Start the script
ENTRYPOINT ["/mariadb.sh"]