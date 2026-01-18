# Planning Guide for Inception Project

---

### Phase 1: Environment & Directory Setup

Set up the file structure and host environment.

1.  **Host Configuration:**
    *   Open `/etc/hosts` on your machine.
    *   Add the line: `127.0.0.1 login.42.fr` (replace `login` with your 42 username).
    *   Create the persistent storage folders on your host machine (this is required for the named volumes to map correctly):
        ```bash
        mkdir -p /home/login/data/mariadb
        mkdir -p /home/login/data/wordpress
        ```

2.  **Project Directory Structure:**
    Replicate the required tree structure exactly.
    ```text
    project_root/
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    ├── secrets/
    │   ├── db_password.txt
    │   ├── db_root_password.txt
    │   └── wp_admin_password.txt
    └── srcs/
        ├── .env
        ├── docker-compose.yml
        └── requirements/
            ├── mariadb/
            │   ├── conf/
            │   ├── tools/
            │   └── Dockerfile
            ├── nginx/
            │   ├── conf/
            │   ├── tools/
            │   └── Dockerfile
            └── wordpress/
                ├── conf/
                ├── tools/
                └── Dockerfile
    ```

---

### Phase 2: Service Configuration (The Dockerfiles)

All images must be based on **Debian Bullseye** (Debian 11) or **Buster** (Debian 10) to satisfy the "penultimate stable" requirement (assuming Bookworm/12 is current stable).

#### 1. NGINX Container
**Goal:** Entry point, HTTPS only (TLSv1.3).
*   **Dockerfile:**
    *   Install `nginx` and `openssl`.
    *   Copy a custom startup script and nginx configuration.
*   **Configuration (`nginx.conf`):**
    *   Listen on port 443 ssl.
    *   `ssl_protocols TLSv1.3;` (Strict requirement).
    *   Set `ssl_certificate` and `key`.
    *   `root /var/www/html;`
    *   Pass PHP requests to the WordPress container: `fastcgi_pass wordpress:9000;`.
*   **Script (`tools/script.sh`):**
    *   Generate a self-signed SSL certificate using `openssl` if it doesn't exist.
    *   Start Nginx in foreground: `nginx -g "daemon off;"`.

#### 2. MariaDB Container
**Goal:** Database backend.
*   **Dockerfile:**
    *   Install `mariadb-server`.
    *   Copy a setup script.
*   **Configuration (`50-server.cnf`):**
    *   Change bind-address to `0.0.0.0` (so WordPress can reach it, default is 127.0.0.1).
    *   Set port to 3306.
*   **Script (`tools/script.sh`):**
    *   Start the MySQL service.
    *   Check if the database exists. If not:
        *   Run SQL commands to create the Database.
        *   Create the User and grant permissions.
        *   Set the Root password.
        *   **Important:** Do not hardcode passwords. Read them from `/run/secrets/` or Environment variables.
    *   Stop the service and restart it in "safe mode" (foreground) so the container stays alive: `mysqld_safe`.

#### 3. WordPress Container
**Goal:** Application logic (PHP-FPM), no Nginx inside.
*   **Dockerfile:**
    *   Install `php-fpm`, `php-mysql`, `curl/wget` (to download WP).
    *   Install **WP-CLI** (Command line interface for WordPress). This makes installation automatable.
*   **Configuration (`www.conf`):**
    *   Edit PHP-FPM config to listen on port `9000` (TCP) instead of the default Unix socket.
*   **Script (`tools/script.sh`):**
    *   Check if `wp-config.php` exists. If not:
        *   `wp core download`
        *   `wp config create` (connect to MariaDB host).
        *   `wp core install` (setup site title, admin user, email).
        *   `wp user create` (create the second non-admin user).
    *   Start PHP-FPM in foreground: `php-fpm7.4 -F`.

---

### Phase 3: Orchestration (Docker Compose)

Create `srcs/docker-compose.yml`.

1.  **Services:** Define `nginx`, `mariadb`, `wordpress`.
2.  **Networks:** Create a custom bridge network (e.g., `inception`). All containers join this.
3.  **Secrets:** Define the secrets pointing to your `./secrets/` folder.
4.  **Volumes:** This is the tricky part. You need **Named Volumes** that map to a specific host path.
    *   *Do not use:* `- /home/login/data:/var/lib/mysql` (This is a bind mount).
    *   *Do use:* Named volume with driver opts.

    ```yaml
    volumes:
      mariadb_data:
        driver: local
        driver_opts:
          type: none
          o: bind
          device: /home/login/data/mariadb  # Absolute path on host
      wordpress_data:
        driver: local
        driver_opts:
          type: none
          o: bind
          device: /home/login/data/wordpress
    ```

---

### Phase 4: Automation (Makefile)

The Makefile goes at the root.

*   **Variables:** Define paths (e.g., `COMPOSE_FILE=./srcs/docker-compose.yml`).
*   **Rules:**
    *   `all`: Create the data directories (`mkdir -p ...`) and run `docker compose up -d --build`.
    *   `down`: `docker compose down`.
    *   `clean`: Stop containers and remove images.
    *   `fclean`: Deep clean. Remove containers, images, networks, **and** delete the contents of `/home/login/data` (be careful with `sudo rm -rf`).
    *   `re`: `fclean` + `all`.

---

### Phase 5: Documentation

You must write three specific files in Markdown.

1.  **README.md:**
    *   **Header:** *This project has been created as part of the 42 curriculum by anemet.*
    *   **Description:** What is this stack? (LEMP stack in Docker).
    *   **Architecture:** Explain the choices (Alpine vs Debian, Volumes).
    *   **Comparisons:**
        *   VM vs Docker (Isolation vs Virtualization).
        *   Secrets vs Env Vars (Security in file vs Memory).
        *   Host vs Docker Network (Port exposure).
    *   **Resources:** Link Docker docs, WP-CLI docs.

2.  **USER_DOC.md:**
    *   Simple instructions: "Run `make`."
    *   "Go to `https://login.42.fr`."
    *   List the credentials (referenced from `.env` or secrets).

3.  **DEV_DOC.md:**
    *   Technical details.
    *   "Config files are located in `srcs/requirements/...`"
    *   "To debug DB, enter container: `docker exec -it mariadb bash`".
    *   Explain how data persistence works via the volume driver opts.

---

### Phase 6: Bonus Part

If you finish the mandatory part, create a specific `docker compose.override.yml` or add to the main one (depending on your preference, though usually, a single compose file is easier for grading).

1.  **Redis:**
    *   Container: Redis image (custom Dockerfile).
    *   Link: Configure WordPress (via `wp-config.php` or a plugin installation script in your WP tool script) to use Redis.
2.  **FTP Server:**
    *   Container: `vsftpd`.
    *   Volume: Mount the `wordpress_volume` so the FTP user can edit files.
3.  **Adminer:**
    *   Container: Adminer (lightweight DB management tool).
    *   Expose port 8080. It should connect to the `mariadb` container.
4.  **Static Website:**
    *   Container: A simple NodeJS or Python server, or even a lightweight HTTPd serving a simple HTML Resume.
5.  **Service of Choice:**
    *   Suggestion: **Portainer** (Visualizer for Docker) or **Cadvisor** (Monitoring).

### Critical Checklist for Success

*   [ ] **TLSv1.3 Check:** Use `openssl s_client -connect login.42.fr:443 -tls1_2` (Should fail) and `-tls1_3` (Should pass).
*   [ ] **Restart Policy:** Kill a container (`docker kill nginx`). Does it restart automatically? (Use `restart: always` or `on-failure` in compose).
*   [ ] **Persistence:** Add a post on WP. Run `make down`. Run `make up`. Is the post still there?
*   [ ] **No Passwords:** Check `docker-compose.yml`. Are there raw passwords? (Fail). Are there `${VARS}`? (Pass).
*   [ ] **Network:** Exec into `wordpress`. Can you `ping mariadb`? (By container name).
*   [ ] **Entrypoint:** Make sure Nginx is the only port exposed to the host (443). DB (3306) and WP (9000) should only be internal.

This plan covers the architecture, configuration, and constraints. Start with the directory structure and the Makefile, then build one container at a time (DB -> WP -> Nginx). Good luck!
