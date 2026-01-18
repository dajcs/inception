Great job! The output confirms that your **NGINX image was successfully built**.

You see `docker ps` is empty because you only **built** the image (the recipe), you haven't **run** the container (the meal) yet. This is exactly what we want for now.

Now, let's move to **Phase 2, Part 2: The MariaDB Container**.

This one is slightly trickier because we need to configure the database to accept connections from the WordPress container (which is on a different "computer" inside the Docker network) and initialize the database users using variables.

---

### 1. Directory Structure

Create the folders for MariaDB:

```bash
mkdir -p srcs/requirements/mariadb/conf
mkdir -p srcs/requirements/mariadb/tools
```

Your structure should look like this:
```text
srcs/requirements/mariadb/
├── Dockerfile
├── conf/
│   └── 50-server.cnf
└── tools/
    └── mariadb.sh
```

---

### 2. The Dockerfile (`srcs/requirements/mariadb/Dockerfile`)

```dockerfile
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
```

---

### 3. The Configuration File (`srcs/requirements/mariadb/conf/50-server.cnf`)

By default, MariaDB only listens to `127.0.0.1` (localhost). This means only processes *inside* the container can talk to it. We need to change this so WordPress (which is in another container) can connect.

```ini
[server]

[mysqld]
# Basic settings
user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
port                    = 3306
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql

# Networking
# This is the CRITICAL part. 0.0.0.0 allows connections from any IP.
bind-address            = 0.0.0.0

# Character sets
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci
```

---

### 4. The Startup Script (`srcs/requirements/mariadb/tools/mariadb.sh`)

This script handles the "Inception" requirement of creating the database and users automatically.

**Note:** We use variables like `${SQL_DATABASE}` here. These variables don't exist yet! We will define them later in the `.env` file and pass them via `docker compose`.

```bash
#!/bin/bash
set -e

# Start the MariaDB service temporarily to configure it
service mariadb start

# Wait a moment for it to start fully
sleep 5

# Check if the database works and if we need to set it up
if [ -d "/var/lib/mysql/$SQL_DATABASE" ]
then
	echo "Database already exists"
else
    # 1. Secure the installation (conceptually similar to mysql_secure_installation)
    # 2. Create the Database
    # 3. Create the User (for WordPress)
    # 4. Give the User permissions
    # 5. Set the Root password

    echo "Setting up MariaDB..."

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Reset root password (this shuts down access without password)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    echo "MariaDB setup complete."
fi

# Stop the temporary service
service mariadb stop

# Start MariaDB in "safe mode" (foreground) so the container stays running
# We use exec so this process replaces the shell script as PID 1
exec mysqld_safe
```

---

### 5. Check your progress

Run the build command for MariaDB to make sure there are no syntax errors in the Dockerfile.

```bash
docker build -t mariadb_test ./requirements/mariadb
```

If that works, we are ready for the third service: **WordPress**.
