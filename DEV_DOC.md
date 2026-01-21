# Development Documentation


### Check Wordpress access at anemet.42.fr

- unsecure access test (should not work, port 80 closed):

```bash
curl -v http://anemet.42.fr 

# * connect to 127.0.0.1 port 80 failed: Connection refused
```
- secure access test (access works, but complains about self-signed certificate):

```bash 
curl -v https://anemet.42.fr 

# *   Trying 127.0.0.1:443...
# * Connected to anemet.42.fr (127.0.0.1) port 443 (#0)
# ...
# * SSL certificate problem: self-signed certificate
# * Closing connection 0
# curl: (60) SSL certificate problem: self-signed certificate
```

- To ignore the self-signed certificate problem, use:

```bash

# -k: Ignore self-signed certificate security problem.
curl -v -k https://anemet.42.fr:443

# *   Trying 127.0.0.1:443...
# * Connected to anemet.42.fr (127.0.0.1) port 443 (#0)
# ...
# * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
# * ALPN, server accepted to use http/1.1
# * Server certificate:
# *  subject: C=FR; ST=IDF; L=Paris; O=42; OU=42; CN=anemet.42.fr; UID=anemet
# *  start date: Jan 21 12:27:35 2026 GMT
# *  expire date: Jan 21 12:27:35 2027 GMT
# *  issuer: C=FR; ST=IDF; L=Paris; O=42; OU=42; CN=anemet.42.fr; UID=anemet
# *  SSL certificate verify result: self-signed certificate (18), continuing anyway.
# * TLSv1.2 (OUT), TLS header, Supplemental data (23):
# > GET / HTTP/1.1
# > Host: anemet.42.fr
# > User-Agent: curl/7.81.0
# > Accept: */*
# 
```

### Checking the logs:

```bash
# check logs for a service:
# docker compose logs -f <service_name>

docker logs mariadb
docker logs wordpress
docker logs nginx

```

### Access the running container:

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
  - WordPress configuration: `srcs/requirements/wordpress/wp-config.php`.
  - Each service has its own configuration file located in the `srcs/requirements/` directory.
  - After making changes to configuration files, rebuild the Docker images using `docker compose build` and then restart the services with `docker compose up -d`.
  - Alternatively it can be done with `make re` command from the repository root directory.




### The mariadb Database

There are two users:

- **`root`**: This is the "Super Admin". Used to **administer the server**, check if other users exist, or fix broken permissions. It has access to *everything*.
- **`anemet` (my Custom User)**: This is the user **WordPress uses**. This user has access to the specific database (`inception`).


- **To login as root:**

```bash
# join mariadb container
docker exec -it mariadb bash

# then inside the container shell, run:
 mysql -u root -p
# Password: SQL_ROOT_PASSWORD from your .env
```

 - check users with:

```sql
SELECT User, Host FROM mysql.user;
```
- check existence of: `root`@`localhost` and `anemet`@`%`.

- **To login as anemet:**

```bash
docker exec -it mariadb bash
# then inside the container shell, run:
 mysql -u anemet -p
# Password: SQL_PASSWORD from your .env
```
- check wordpress database tables with:
```sql
USE inception;
SHOW TABLES;
```
- expect: list of about 12 tables (`wp_users`, `wp_posts`, `wp_options`, etc.)
---

### The "Persistence" Test

This proves that the Docker Volumes are working.

1.  **In Browser:**
    - Log in to WordPress (`https://anemet.42.fr/wp-admin/`).
    - Create a new Post. Title it: **"Hello 42 Evaluation"**.
    - Publish it.

2.  **Check Browser:**
    - Main wordpress page (`https://anemet.42.fr/`)
    - **Expectation:** The post you created should be visible.

3.  **The Crash Test:**
    - reboot the VM (`sudo reboot`)
    - Main wordpress page (`https://anemet.42.fr/`)
    - **Expectation:** The post **must still be there**. 

3.  **The Total Wipe Test:**
    - Total clean of all docker containers **and named volumes** (`make fclean`)
    - Start the project again: `make`.
    - Main wordpress page (`https://anemet.42.fr/`)
    - **Expectation:** The post **shouldn't be there**, because we wiped the named volumes in `/home/anemet/data/mariadb` and `/home/anemet/data/wordpress`.


## Redis (bonus 1)

- Go to the website `https://anemet.42.fr/wp-admin` and login as supervisor.
- In the left sidebar, navigate to "Plugins" `https://anemet.42.fr/wp-admin/plugins.php`
- Click on "Redis Object Cache" settings link or go to `https://anemet.42.fr/wp-admin/options-general.php?page=redis-cache`
- Check for:
  - Status: 	Connected
  - Filesystem: 	Writeable
  - Redis: 	Reachable 


## FTP test (bonus 2)

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
    *   **Password**: `<...>` (the FTP_PASSWORD you set in the .env file)

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

## Static Website serving (bonus 3)

This setup effectively implements a **Microservices Architecture** pattern using a **Reverse Proxy**.

This is happening when requesting `https://anemet.42.fr/cv/` into the browser.

### 1. The Architecture Visualized

```text
       USER (Browser)
          |
          |  1. HTTPS Request (Port 443)
          v
  [ CONTAINER: NGINX (Main) ]  <-- The "Front Door" / Reverse Proxy
          |
          |  2. Decrypts SSL
          |  3. Sees "/cv/" path
          |  4. Proxies request (HTTP Port 80)
          v
  [ CONTAINER: WEBSITE ]       <-- The "Static File Server"
          |
          |  5. Fetches /var/www/html/cv/index.html
          |
          ^ Returns Content
```

---

### 2. The Step-by-Step Flow

#### Step 1: The Browser Connection
The browser connects to `anemet.42.fr` on port **443**.
*   The **Main Nginx container** accepts this connection.
*   It performs the SSL Handshake (using certificates) to decrypt the data.
*   It looks at the requested URL: `/cv/`.

#### Step 2: The Main Nginx "Routing"
Inside `srcs/requirements/nginx/conf/nginx.conf`, the server reads this block:

```nginx
location ^~ /cv/ {
    include /etc/nginx/proxy_params;
    proxy_pass http://website:80;
}
```

*   **`location ^~ /cv/`**: This tells Nginx, "If the URL starts with `/cv/`, stop looking for other rules (like PHP) and execute this block immediately."
*   **`proxy_pass http://website:80`**: Here is the magic.
    *   **`http`**: Switch protocol to standard HTTP (internal network is safe).
    *   **`website`**: This is the **Host**. Docker's internal DNS resolver looks at your `docker-compose.yml`, sees the service named `website`, and resolves it to that container's internal IP address (e.g., `172.18.0.4`).
    *   **`:80`**: The port the Website container is listening on.

The Main Nginx acts as a client here. It forwards the request to the Website container.

#### Step 3: The Website Container

The **Website container** (running its own lightweight Nginx) receives a request for:
`GET /cv/`

Inside `srcs/requirements/bonus/website/Dockerfile`, we did this:
```dockerfile
# We created a subdirectory matching the URL path
COPY tools/ /var/www/html/cv/
```

And its internal Nginx config (`conf/nginx.conf`) says:
```nginx
root /var/www/html;
```

So, when the request for `/cv/` comes in:
1.  Nginx takes the `root` (`/var/www/html`).
2.  Appends the request path (`/cv/`).
3.  Looks for the index file.
4.  Result: It serves `/var/www/html/cv/index.html`.

If we hadn't moved the files into a `/cv` folder inside the container, Nginx would have looked for `/var/www/html/cv/` and found nothing (404 Not Found), because the files would have been sitting at the root.

#### Step 4: The Return Trip
1.  The **Website container** sends the HTML content back to the **Main Nginx**.
2.  The **Main Nginx** receives the HTML.
3.  It re-encrypts the data (SSL).
4.  It sends the response back to your **Browser**.

---


## Adminer (bonus 4)


A classic example of **Routing** and **Proxying**. Here is the detailed breakdown of what happens when requesting `https://anemet.42.fr/adminer`.

### 1. The Architecture Visualized

```text
       USER (Browser)
          |
          |  1. HTTPS Request "GET /adminer/"
          v
  [ CONTAINER: NGINX ] (Port 443)
          |
          |  2. Matches location /adminer/
          |  3. Proxies to "http://adminer:8080/adminer/"
          v
  [ CONTAINER: ADMINER ] (Port 8080)
          |
          |  4. PHP Server receives request
          |  5. Maps URI to File System
          |  6. Executes /var/www/html/adminer/index.php
          |
          v
     Generates HTML Login Form
          |
          ^ (Returns back up the chain)
```

---

### 2. Step-by-Step Execution

#### Step 1: The Browser Request
The browser sends an encrypted request to `https://anemet.42.fr/adminer/`.
*   **Protocol:** HTTPS
*   **Port:** 443

#### Step 2: Nginx Decryption & Routing
The **Nginx Container** receives the traffic. It decrypts the SSL using certificates.
It then looks at its configuration file (`nginx.conf`) to decide what to do with the path `/adminer/`.

It finds this block:
```nginx
location ^~ /adminer/ {
    proxy_pass http://adminer:8080;
}
```
*   **Interpretation:** "Any request starting with `/adminer/` must be forwarded to the host named `adminer` on port `8080`."

#### Step 3: The Internal Proxy
Nginx acts as a client. It creates a **new** HTTP request inside the Docker network.
*   **Destination:** `adminer` (Docker resolves this name to the IP address of the adminer container).
*   **Port:** 8080.
*   **Path:** It preserves the path `/adminer/`.

#### Step 4: The Adminer Container (PHP Server)
The **Adminer Container** is running this command:
```bash
php -S 0.0.0.0:8080 -t /var/www/html
```
*   **`-S 0.0.0.0:8080`**: PHP is listening for web requests on port 8080.
*   **`-t /var/www/html`**: This is the "Document Root". This is the base folder for looking for files.

When the request for `/adminer/` arrives:
1.  PHP starts at the root: `/var/www/html`
2.  It appends the requested path: `/adminer/`
3.  Full path: `/var/www/html/adminer/`
4.  Since it is a directory, it looks for an index file (`index.php`), which is downloaded there in the startup script.

#### Step 5: Execution & Response
PHP executes the `adminer-4.8.1.php` code. This script generates the HTML for the login page.
This HTML is sent back to Nginx -> Nginx encrypts it -> Nginx sends it to the browser.

---

### 3. What happens when at Login? (The Database Connection)

When filling the login form (Server: `mariadb`, User: `anemet`...) and clicking "Login":

1.  **Browser:** POST request to `/adminer/`.
2.  **Nginx:** Forwards POST to **Adminer Container**.
3.  **Adminer Container:** PHP reads the form data. It sees "Server: mariadb".
4.  **Internal Connection:** The PHP script inside the Adminer container attempts to open a MySQL connection to the host `mariadb`.
5.  **Docker DNS:** Docker resolves `mariadb` to the IP of your **MariaDB Container**.
6.  **MariaDB Container:** Authenticates the user.
7.  **Result:** MariaDB sends table data to Adminer -> Adminer generates HTML -> Nginx -> Browser.

### Why did we set it up this way?

1.  **Zero Configuration Nginx:** By using the PHP built-in server inside the Adminer container, we didn't need to install a second full Nginx server inside the Adminer container. It keeps the container very lightweight.
2.  **Path Consistency:** We created the folder `/var/www/html/adminer` inside the container specifically so that the URL `/adminer/` maps perfectly to the file system. If we had put the file at the root `/var/www/html/index.php`, we would have needed complex URL rewriting rules in Nginx to strip the `/adminer` prefix.

### 4. Testing Adminer

- Open browser to: `https://anemet.42.fr/adminer/`
- Login to Adminer:
  - System: MySQL
  - Server: mariadb (This is the container name)
  - Username: anemet (the SQL_USER)
  - Password: <...> (the SQL_PASSWORD)
  - Database: inception (the SQL_DATABASE)
- Upon successful login, the WordPress database tables should be visible.


## Portainer (bonus 5)

### 0. Make sure the Portainer is accessible

The Portainer service should be accessed and and admin user needs to be created in the first 5 minutes after starting the containers. 

When accessing `https://anemet.42.fr/portainer/`, if there is a timeout, we need to restart.

```bash
docker restart portainer
```
Now try to access again within 5 minutes and create the admin user.


### 1. Understanding the Traffic Flow

We have three "doors" open to the Portainer container.

#### A. The Nginx Proxy (`https://anemet.42.fr/portainer/`)
This is the "Nice" way to access Portainer.
1.  **Browser** connects to Port **443** (Nginx Container).
2.  **Nginx** handles the security (SSL Certificate).
3.  **Nginx** strips the `/portainer` prefix and forwards traffic internally to `portainer:9000`.
4.  **Portainer** sees an unencrypted HTTP request coming from Nginx.
5.  *Benefit:* We use the "valid" SSL certificate generated for the subject.

#### B. Direct HTTP (`http://anemet.42.fr:9000`)
1.  **Browser** connects directly to Port **9000** on the VM.
2.  **Docker** maps this directly to Port 9000 inside the Portainer container.
3.  **Portainer** responds directly.
4.  *Risk:* If there are password in the request, these can be sniffed on the network because there is no encryption.

#### C. Direct HTTPS (`https://anemet.42.fr:9443`)
1.  **Browser** connects to Port **9443** on the VM.
2.  **Docker** maps this to Port 9443 inside the container.
3.  **Portainer** uses its **own** internal SSL certificate (Self-Signed).
4.  *Result:* The connection is encrypted, but the browser warns you ("Not Secure") because it doesn't trust the certificate Portainer generated for itself.

---

