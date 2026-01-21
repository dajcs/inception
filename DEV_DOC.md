# Development Documentation


### Check Wordpress access at anemet.42.fr

- unsecure access test (should not work, port 80 closed):

```bash
curl -v http://anemet.42.fr 
```
- secure access test (access works, but complains about self-signed certificate):

```bash 
curl -v https://anemet.42.fr # expect: self-signed certificate complaint
```

- To ignore the self-signed certificate warning, use:

```bash
# -k: Ignore self-signed certificate security warning.
curl -v -k https://anemet.42.fr:443
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

## Static Website serving using Reverse Proxy (bonus 3)

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
  - Username: anemet (Your SQL_USER)
  - Password: apass123 (Your SQL_PASSWORD)
  - Database: inception (Your SQL_DATABASE)
- Upon successful login, the WordPress database tables should be visible.


## Portainer (bonus 5)

Here is the breakdown of the three different ways you can currently access Portainer, followed by the explanation of the persistence issue and the fixed Makefile.

### 1. Understanding the Traffic Flow

You currently have three doors open to your Portainer container.

#### A. The Nginx Proxy (`https://anemet.42.fr/portainer/`)
This is the "Clean" way, matching the project requirements.
1.  **Browser** connects to Port **443** (Nginx Container).
2.  **Nginx** handles the security (SSL Certificate).
3.  **Nginx** strips the `/portainer` prefix and forwards traffic internally to `portainer:9000`.
4.  **Portainer** sees an unencrypted HTTP request coming from Nginx.
5.  *Benefit:* You use the valid SSL certificate generated for the subject.

#### B. Direct HTTP (`http://anemet.42.fr:9000`)
1.  **Browser** connects directly to Port **9000** on your VM.
2.  **Docker** maps this directly to Port 9000 inside the Portainer container.
3.  **Portainer** responds directly.
4.  *Risk:* Your password travels in plain text. Anyone sniffing the network can steal your credentials.

#### C. Direct HTTPS (`https://anemet.42.fr:9443`)
1.  **Browser** connects to Port **9443** on your VM.
2.  **Docker** maps this to Port 9443 inside the container.
3.  **Portainer** uses its **own** internal SSL certificate (Self-Signed).
4.  *Result:* The connection is encrypted, but your browser warns you ("Not Secure") because it doesn't trust the certificate Portainer generated for itself.

---

