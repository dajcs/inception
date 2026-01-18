# Orchestration with Docker Compose

We need to tell Docker how to run these three containers together, how they talk to each other, and where they store their data on your computer.

We will create two files in `srcs/`:
1.  `.env` (To store passwords and configuration variables).
2.  `docker-compose.yml` (The master plan).

---

### Step 1: The `.env` file

Create a file named `.env` inside `srcs/`.
This file is used to inject variables into your containers so you don't hardcode passwords.

**Important:** Replace `anemet` with your actual login and choose secure passwords.
**Constraint:** The admin user cannot contain "admin" or "administrator".

```bash
# srcs/.env

# Domain
DOMAIN_NAME=anemet.42.fr

# MySQL Setup
SQL_DATABASE=inception
SQL_USER=anemet
SQL_PASSWORD=userpass123
SQL_ROOT_PASSWORD=rootpass123
SQL_HOST=mariadb:3306

# WordPress Setup
SITE_TITLE=Inception
WP_ADMIN_USER=supervisor
WP_ADMIN_PASSWORD=adminpass123
WP_ADMIN_EMAIL=supervisor@student.42.fr

WP_USER=regular
WP_PASSWORD=regularpass123
WP_EMAIL=regular@student.42.fr
```

---

### Step 2: The `docker-compose.yml` file

Create `srcs/docker-compose.yml`.

This file is strict about indentation (use 2 spaces).
Here is the logic you need to implement to pass the evaluation:
1.  **Build:** Tells Docker to use the Dockerfiles you just wrote.
2.  **Depends_on:** Ensures Database starts before WordPress, and WordPress starts before NGINX.
3.  **Volumes:** The tricky part. We must use **Named Volumes** that map to a specific path on your hard drive (`/home/anemet/data/...`).

**Important:** Replace `/home/anemet/data` with your actual home directory path.

```yaml
version: '3'

services:
  mariadb:
    container_name: mariadb
    build: ./requirements/mariadb
    image: mariadb
    # Load variables from .env file
    env_file:
      - .env
    networks:
      - inception
    volumes:
      - mariadb_data:/var/lib/mysql
    restart: always

  wordpress:
    container_name: wordpress
    build: ./requirements/wordpress
    image: wordpress
    env_file:
      - .env
    networks:
      - inception
    volumes:
      - wordpress_data:/var/www/html
    # Wait for mariadb to be ready
    depends_on:
      - mariadb
    restart: always

  nginx:
    container_name: nginx
    build: ./requirements/nginx
    image: nginx
    env_file:
      - .env
    ports:
      - "443:443"
    networks:
      - inception
    volumes:
      # Nginx needs access to WP files to serve static assets (images, css)
      - wordpress_data:/var/www/html
    depends_on:
      - wordpress
    restart: always

# Define the network
networks:
  inception:
    driver: bridge

# Define the volumes
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      # ABSOLUTE PATH TO YOUR HOST MACHINE FOLDER
      device: /home/anemet/data/mariadb

  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      # ABSOLUTE PATH TO YOUR HOST MACHINE FOLDER
      device: /home/anemet/data/wordpress
```

---

### Step 3: Prepare the Host System

Before running this, you **MUST** create the folders on your computer, or Docker will complain it cannot find the "device" path.

Run these commands in your terminal:

```bash
# Replace 'anemet' with your login
mkdir -p /home/anemet/data/mariadb
mkdir -p /home/anemet/data/wordpress
```

Also, ensure your `/etc/hosts` has your domain mapped to localhost:
```bash
# Open file (requires sudo)
sudo nano /etc/hosts

# Add this line if not present:
127.0.0.1	anemet.42.fr
```

---

### Step 4: Launching the Project!

Now, you are ready to launch the entire stack.

1.  Go to the `srcs` directory.
2.  Run the compose command:

```bash
docker compose up -d --build
```

*   `up`: Start the containers.
*   `-d`: Detached mode (run in background).
*   `--build`: Force rebuild the images to make sure your latest changes are used.

### How to check if it works?

1.  **Check status:**
    ```bash
    docker ps
    ```
    You should see 3 containers running.

2.  **Check logs:**
    If something crashes, check why:
    ```bash
    docker logs wordpress
    docker logs mariadb
    docker logs nginx
    ```

3.  **Access the site:**
    Open your browser (Firefox/Chrome) and go to: `https://anemet.42.fr`
    (Accept the security warning because our certificate is self-signed).

If you see the WordPress page, **Congratulations! You have completed the Mandatory part.**
