# User Documentation


## Instructions

### Clone the repository

```bash
git clone <link_to_repository>
```

### 1. Host Setup
Map the domain name to the local machine. Open `/etc/hosts` and add/edit the following line:

```bash
127.0.0.1   anemet.42.fr
```

### 2. Environment Variables
The project relies on a `.env` file in `srcs/`. This file is not included in the repository for security reasons. 

Create a `.env` file with the variables from the template below:

```env
# .env template
# Domain
DOMAIN_NAME=anemet.42.fr

# Domain rootless setup
# DOMAIN_NAME=localhost:443

# MySQL Setup
SQL_DATABASE=inception
SQL_USER=anemet
SQL_PASSWORD=<...>
SQL_ROOT_PASSWORD=<...>
SQL_HOST=mariadb:3306

# WordPress Setup
SITE_TITLE=Inception
WP_ADMIN_USER=supervisor
WP_ADMIN_PASSWORD=<...>
WP_ADMIN_EMAIL=supervisor@super.42luxembourg.lu
WP_USER=anemet
WP_PASSWORD=<...>
WP_EMAIL=anemet@student.42luxembourg.lu

# FTP Setup
FTP_USER=ftpuser
FTP_PASSWORD=<...>
```
Make sure to replace the placeholder `<...>` with secure passwords.


### 3. Execution

Enter the repository directory and execute make to start the infrastructure.

```bash
cd inception/
make
```

Use the Makefile to manage the lifecycle of the application.

```bash
make        # Builds and starts the infrastructure
make build  # Rebuilds images and starts
make down   # Stops the containers
make re     # Recreates containers without rebuilding images
make clean  # Stops containers and removes images
make fclean # Deep clean: removes containers, images, volumes, and data
```

### 4. Access Points

Once up, the services are accessible at:

| Service | URL | Credentials (Default) |
| :--- | :--- | :--- |
| **WordPress** | `https://anemet.42.fr` | User: `anemet` / Pass: in .env |
| **Adminer** | `https://anemet.42.fr/adminer/` | DB User/Pass from .env |
| **Portainer** | `https://anemet.42.fr/portainer/` | Create Admin on first launch |
| **Static CV** | `https://anemet.42.fr/cv/` | N/A |
| **FTP** | `ftp -p anemet.42.fr` (Port 21) | User: `ftpuser` / Pass: in .env |

### 5. Data Persistence

A host reboot or container recreation does not lead to data loss. The following Docker volumes are used:
| Volume Name | Purpose |
| :--- | :--- |
| `srcs_mariadb_data` | Persists MariaDB database files |
| `srcs_wordpress_data` | Persists WordPress files (uploads, themes, plugins) |
| `srcs_portainer_data` | Persists Portainer data |
