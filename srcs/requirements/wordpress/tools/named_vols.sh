#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    named_vols.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: anemet <anemet@student.42luxembourg.lu>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/16 17:18:42 by anemet            #+#    #+#              #
#    Updated: 2026/01/16 17:18:51 by anemet           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Ensure the parent directory exists
if [ ! -d "/home/anemet/data" ]; then
        mkdir -p /home/anemet/data/mariadb
        mkdir -p /home/anemet/data/wordpress
fi