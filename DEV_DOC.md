# Development Documentation

Technical details about the Docker setup and support, e.g.:
   - Customizing config files
   - To debug DB, enter container: `docker exec -it mariadb bash`
   - Data persistence works via the volume driver options


- check the logs:
```bash
# check logs for a service:
# docker compose logs -f <service_name>

docker logs mariadb
docker logs wordpress
docker logs nginx

```
- access the running container:
```bash
# access a running container:
# docker exec -it <container_name> bash

# wordpress:
docker exec -it wordpress bash
# mariadb:
docker exec -it mariadb bash
# nginx:
docker exec -it nginx bash
```

### Customizing configuration files:

  - Nginx configuration: edit the file located at `srcs/requirements/nginx/nginx.conf` before building the containers.
  - MariaDB configuration: modify the `my.cnf` file found in `srcs/requirements/mariadb/my.cnf` to adjust database settings.
	*   WordPress configuration: `srcs/requirements/wordpress/wp-config.php`.
  - Each service has its own configuration file located in the `srcs/requirements/` directory.
  - After making changes to configuration files, rebuild the Docker images using `docker compose build` and then restart the services with `docker compose up -d`.
      - Alternatively it can be done with `make re` command from the repository root directory.




### 1. Login to the Database

There are two users:

- **`root`**: This is the "Super Admin". Used to **administer the server**, check if other users exist, or fix broken permissions. It has access to *everything*.
- **`anemet` (my Custom User)**: This is the user **WordPress uses**. This user has access to the specific database (`inception`).

---

### 2. How to Login

**To login as root:**
```bash
docker exec -it mariadb mysql -u root -p
# Password: SQL_ROOT_PASSWORD from your .env
```
 and run:
```sql
SELECT User, Host FROM mysql.user;
```
- check existence of: `root`@`localhost` and `anemet`@`%`.

**To login as anemet:**
```bash
docker exec -it mariadb mysql -u anemet -p
# Password: SQL_PASSWORD from your .env
```
and run:
```sql
USE inception;
SHOW TABLES;
```
- expect: list of about 12 tables (`wp_users`, `wp_posts`, `wp_options`, etc.)
---

#### The "Persistence" Test

This proves that the Docker Volumes are working.

1.  **In your Browser:**
    - Log in to WordPress (`https://localhost:8443/wp-admin/`).
    - Create a new Post. Title it: **"Hello 42 Evaluation"**.
    - Publish it.

2.  **In the Terminal (Database):**
    - Login to SQL.
    - Run this query to find your post:
        ```sql
        USE inception;
        SELECT post_title, post_content FROM wp_posts WHERE post_title='Hello 42 Evaluation';
        ```
    - **Expectation:** You should see the text you just wrote in the browser appearing here in the terminal.

3.  **The Crash Test:**
    - Exit SQL (`exit`).
    - Stop the project: `docker-compose -f srcs/docker-compose.yml down`.
    - Start the project again: `docker-compose -f srcs/docker-compose.yml up -d`.
    - Login to SQL again and run the `SELECT` query above.
    - **Expectation:** The post **must still be there**. If it disappeared, your volumes are not configured correctly.

#### D. Check the WordPress Users
The subject requires two WordPress users (one admin, one regular).
```sql
USE inception;
SELECT user_login, user_email FROM wp_users;
```
*   **Expectation:** You should see the admin user (e.g., `supervisor`) and the regular user (e.g., `regular`) that you defined in your `.env` file.
