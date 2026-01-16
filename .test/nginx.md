Since you are new to Docker, think of it this way:
*   **The Dockerfile** is a recipe. It tells Docker: "Take this OS, install these programs, move these files here, and get ready to run."
*   **The Image** is the cooked meal resulting from the recipe (a snapshot of the system).
*   **The Container** is the meal being eaten (the running process).

Here is the exact setup for your **NGINX** service.

### 1. Directory Structure

First, ensure your folders are created exactly like this inside your project root:

```bash
srcs/requirements/nginx/
├── Dockerfile
├── conf/
│   └── nginx.conf
└── tools/
    └── nginx_start.sh
```

---

### 2. The Dockerfile (`srcs/requirements/nginx/Dockerfile`)

This file tells Docker how to build the NGINX image.

```dockerfile
# Use the penultimate stable version of Debian (Debian 11 Bullseye)
FROM debian:bullseye

# 1. Update package manager and install NGINX and OpenSSL
# -y means "yes" to prompts
RUN apt-get update && apt-get install -y nginx openssl

# 2. Create a folder to store the SSL certificate and key
RUN mkdir -p /etc/nginx/ssl

# 3. Copy our configuration file to the container
# We copy it to conf.d so NGINX reads it automatically
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# 4. Copy the startup script
COPY ./tools/nginx_start.sh /var/www/nginx_start.sh

# 5. Give execution rights to the script
RUN chmod +x /var/www/nginx_start.sh

# 6. Define the command that runs when the container starts
ENTRYPOINT ["/var/www/nginx_start.sh"]
```

---

### 3. The Configuration File (`srcs/requirements/nginx/conf/nginx.conf`)

This tells NGINX how to handle the traffic.
**Important:** Replace `login` with your actual 42 username in `server_name`.

```nginx
server {
    # Listen on port 443 for SSL (HTTPS)
    listen 443 ssl;
    listen [::]:443 ssl;

    # Set the domain name
    server_name login.42.fr;

    # SSL Certificate locations (we will generate these in the script below)
    ssl_certificate /etc/nginx/ssl/inception.crt;
    ssl_certificate_key /etc/nginx/ssl/inception.key;

    # Encryption Protocol - TLSv1.3 ONLY (Project Requirement)
    ssl_protocols TLSv1.3;

    # Root directory for the website files
    root /var/www/html;
    index index.php index.html index.htm;

    # First try to serve the file, if missing, try index.php
    location / {
        try_files $uri $uri/ =404;
    }

    # PHP Handling
    # Pass any request ending in .php to the WordPress container
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        
        # 'wordpress' is the name of the OTHER container we will create later.
        # Docker's internal DNS resolves 'wordpress' to the IP of that container.
        # Port 9000 is the default PHP-FPM port.
        fastcgi_pass wordpress:9000;
    }
}
```

---

### 4. The Startup Script (`srcs/requirements/nginx/tools/nginx_start.sh`)

We need a script because we have to generate the SSL certificate *inside* the container before NGINX starts.

**Important:** Replace `login` in the `CN=` and `UID=` fields with your actual username.

```bash
#!/bin/bash

# check if the certificate already exists
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Nginx: Setting up SSL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr/UID=login"
fi

# Start Nginx
# 'daemon off;' is crucial. Docker containers exit if the main process
# stops. By default, Nginx runs in the background. We force it to 
# run in the foreground so the container stays alive.
exec nginx -g 'daemon off;'
```

---

### How to test this (Optional right now)

You cannot fully test this yet because the `wordpress` container doesn't exist, so NGINX will crash if it tries to talk to it.

However, if you want to verify the **Build** works:

1.  Go to `srcs/`
2.  Run: `docker build -t nginx_test ./requirements/nginx/`

If you see "Successfully built...", your syntax is correct.

### Summary of what we just did:
1.  **OS:** We took Debian Bullseye.
2.  **Tools:** Installed NGINX and OpenSSL.
3.  **Config:** Setup NGINX to listen on port 443, enforce TLS 1.3, and forward PHP requests to a (future) container named `wordpress`.
4.  **Script:** Created a script that makes a fake ID card (Self-signed SSL cert) and keeps the server running.
