# Inception

*This project has been created as part of the 42 curriculum by anemet.*

## Instructions: [User Documentation](USER_DOC.md)

## Technical Details: [Developer Documentation](DEV_DOC.md)


## Description

This project aims to broaden the knowledge of system administration by using **Docker**. It requires creating a complete multi-service infrastructure using **Docker Compose**, simulating a real-world web server deployment.

Instead of using a monolithic approach (everything on one server), this project adopts a **Microservices Architecture**, where each service runs in its own isolated container.

### Overview

The infrastructure consists of a **WordPress** website running on a **LEMP** stack (Linux, Nginx, MariaDB, PHP-FPM), secured by TLSv1.2/1.3.

**Mandatory Services:**
*   **Nginx:** The entry point and Reverse Proxy handling SSL/TLS.
*   **MariaDB:** The database for WordPress.
*   **WordPress:** The PHP-FPM container processing dynamic content.

**Bonus Services:**
*   **Redis:** In-memory data structure store used as a cache for WordPress.
*   **FTP Server (vsftpd):** Allows direct file access to the WordPress volume.
*   **Adminer:** A lightweight database management interface (GUI).
*   **Portainer:** A GUI for managing the Docker environment.
*   **Static Website:** A dedicated container serving a Resume/CV.

### Design Choices

1.  **Debian Bullseye:** As per the subject requirements, all Dockerfiles are built `FROM debian:bullseye`.
2.  **Nginx as Reverse Proxy:** Nginx is the only container exposing ports 80/443. All other services (Website, Adminer, Portainer) are routed through Nginx paths (e.g., `/adminer`, `/cv`) to ensure a unified SSL entry point.
3.  **Network Isolation:** All containers communicate via a private Docker bridge network (`inception`). Only necessary ports are exposed to the host.

---

### Conceptual Comparisons

#### Virtual Machines (VM) vs Docker
*   **VM:** Virtualizes the **Hardware**. Each VM runs a full Operating System (Kernel + User Space) on top of a Hypervisor. It is heavy, slow to boot, but offers high isolation.
*   **Docker:** Virtualizes the **Operating System**. Containers share the Host's Kernel but have isolated User Spaces (bins/libs). They are lightweight, start instantly, and use fewer resources.

#### Secrets vs Environment Variables
*   **Environment Variables:** Stored in the container's environment. Easy to use and standard for configuration. However, they can be viewed via commands like `docker inspect`.
*   **Secrets (Docker Swarm/K8s):** Files encrypted at rest and mounted into `/run/secrets/` only when the container is running. This is the more secure industry standard for sensitive data (passwords, keys), though for this project, environment variables were used for simplicity.

#### Docker Network vs Host Network
*   **Host Network:** The container shares the host's networking namespace. If the container listens on port 80, it binds directly to the host's port 80. Fast, but causes port conflicts and offers no isolation.
*   **Docker Network (Bridge):** Containers get their own IP addresses inside a virtual network. They can talk to each other via DNS names (e.g., `ping mariadb`). Ports must be explicitly mapped (`-p 80:80`) to be accessible from the outside.

#### Docker Volumes vs Bind Mounts
*   **Named Volumes:** Maps a specific file or directory on the **Host** machine to the container (e.g., `/home/anemet/data/wordpress`). Good for development and persistence where exact host location matters.
*   **Docker Volumes:** Managed entirely by Docker (`/var/lib/docker/volumes/`). Easier to back up, migrate, and safer as they are not dependent on the host's specific folder structure.

---


## Resources & AI Usage

### References
*   **Docker Documentation:** Reference for Dockerfiles and Compose specification.
*   **Nginx Documentation:** Used for configuring Reverse Proxy, SSL, and `location` blocks.
*   **WP-CLI Handbook:** For automating WordPress installation via script.
*   **Vsftpd Config:** Configuring Passive Mode for FTP behind NAT/Docker.

### AI Usage Disclosure
Generative AI (Gemini Pro 3.0/ChatGPT) was used in this project for the following tasks:

1.  **Debugging Nginx Routing:** AI helped troubleshoot the `proxy_pass` directives for the bonuses, specifically how to handle trailing slashes and header forwarding for **Portainer** and **Adminer**.
2.  **Scripting Logic:** Generating the bash logic for `mariadb.sh` and `create_wordpress.sh` to handle the "wait-for-service" loops (ensuring DB is ready before WP connects).
3.  **FTP Passive Mode:** Explaining and generating the correct `vsftpd.conf` settings (`pasv_address`, `pasv_min_port`) to allow FTP to work inside a Docker container.
4.  **Resume Content:** Formatting the provided CV text into clean HTML/CSS structure for the Static Website bonus.
```
