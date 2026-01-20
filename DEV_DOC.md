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

### The "Persistence" Test

This proves that the Docker Volumes are working.

1.  **In Browser:**
    - Log in to WordPress (`https://anemet.42.fr:443/wp-admin/`).
    - Create a new Post. Title it: **"Hello 42 Evaluation"**.
    - Publish it.

2.  **Check Browser:**
    - Main wordpress page (`https://anemet.42.fr:443/`)
    - **Expectation:** The post you created should be visible.

3.  **The Crash Test:**
    - Remove all containers and rebuild configuration (`make re`)
    - Main wordpress page (`https://anemet.42.fr:443/`)
    - **Expectation:** The post **must still be there**. If it disappeared, your volumes are not configured correctly.

3.  **The Total Wipe Test:**
    - Total clean of all docker containers **and named volumes** (`make fclean`)
    - Start the project again: `make`.
    - Main wordpress page (`https://anemet.42.fr:443/`)
    - **Expectation:** The post **shouldn't be there**, because we wiped the named volumes in `/home/anemet/data/mariadb` and `/home/anemet/data/wordpress`.


## Bonus FTP test

### 1. Create a dummy file to upload
Create a small text file on your host machine to test the upload feature:

```bash
echo "Hello from Inception FTP" > test_ftp.txt
```

### 2. Connect to the FTP Server
Run the following command. The `-p` flag forces **Passive Mode**, which is required for the Docker port mapping to work correctly.

```bash
ftp -p localhost
```

### 3. Interactive Session
Once inside the FTP shell, follow these steps:

1.  **Login:**
    *   **Name**: `ftpuser`
    *   **Password**: `fpass123`

2.  **List Files (Test Read Access):**
    You should see the WordPress files (`index.php`, `wp-config.php`, etc.).
    ```ftp
    ls
    ```

3.  **Upload File (Test Write Access):**
    Upload the file we created in step 2.
    ```ftp
    put test_ftp.txt
    ```

4.  **Verify via Browser (Optional):**
    Open your browser to `https://anemet.42.fr/test_ftp.txt`. You should see "Hello from Inception FTP".

5.  **Delete File (Test Delete Access):**
    Clean up the file.
    ```ftp
    delete test_ftp.txt
    ```

6.  **Exit:**
    ```ftp
    bye
    ```

---
