    *   Technical details.
    *   "Config files are located in `srcs/requirements/...`"
    *   "To debug DB, enter container: `docker exec -it mariadb bash`".
    *   Explain how data persistence works via the volume driver opts.


- check the logs:
```bash
docker compose logs -f <service_name>

# or

docker logs mariadb
docker logs wordpress
docker logs nginx

```
- access the running container:
```bash
# access any running container:
# docker exec -it <container_name> bash

# wordpress:
docker exec -it wordpress bash
# mariadb:
docker exec -it mariadb bash
# nginx:
docker exec -it nginx bash
```

- explain how to customize configuration files:
  *   "To customize the Nginx configuration, edit the file located at `srcs/requirements/nginx/nginx.conf` before building the containers."
  *   "For MariaDB, you can modify the `my.cnf` file found in `srcs/requirements/mariadb/my.cnf` to adjust database settings."
  *   "After making changes to configuration files, ensure to rebuild the Docker images using `docker compose build` and then restart the services with `docker compose up -d`."
    *   "Each service has its own configuration file located in the `srcs/requirements/` directory."
	*   "For PHP-FPM, the configuration file is located at `srcs/requirements/php-fpm/php-fpm.conf`."
	*   "For WordPress, you can find the configuration file at `srcs/requirements/wordpress/wp-config.php`."



