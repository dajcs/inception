# Inception

## General Guidelines

- All the files required for the configuration must be placed in a `srcs` folder
- A Makefile is also required and must be located at the root of the directory.
  It must set up the entire application (i.e., it has to build the Docker images
  using `docker compose` and start the containers).


## Mandatory Part

We have to set up a small infrastructure composed of different services.
The whole project has to be done using Docker and Docker-Compose.

- Each Docker image must have the same name as its corresponding service
- Each service has to run in a dedicated container
- The containers must be built from the penultimate stable version of Debian.
- It has to be written one Dockerfile per service
- The Dockerfiles must be called in the `docker-compose.yml` by Makefile.
- This means we have to build the Docker images ourselves
- It is forbidden to pull ready made Docker images from DockerHub (Debian being
  excluded from this rule)
- We have to set up:
  - A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only
  - A Docker container that contains WordPress + php-fpm (it must be installed
    and configure) only, without nginx
  - A Docker container that contains MariaDB only, without nginx
  - A volume that contains our WordPress database
  - A second volume that contains our WordPress website files
  - We must use Docker **named volumes** for these two persistent data storages.
    Bind mounts are **not allowed** for these volumes.
  - Both named volumes must store their data inside `/home/login/data` on the host.
    Replace `login` with your actual login (anemet).
  - A `docker-network` that establishes the connection between the containers.

- The containers have to restart in case of a crash.
- Using host or --link or links is forbidden.
- The network line must be present in the docker-compose.yml file.
- The containers must not be started with a command running an infinite loop,
  this also applies to any command used as entrypoint, or used in entrypoint scripts.
- The following are a few prohibited hacky patches: tail -f, bash, sleep infinity,
  while true, etc.
- In the WordPress database, there must be two users, one of them being the
  administrator. The administrator's username can't contain admin/Admin or
  administrator/Administrator.
- The volumes will be available in the /home/login/data folder of the host machine.
  Replace login with your actual login (anemet).
- We have to configure our domain name so it points to our local IP address.
  This domain name must be `login.42.fr`, replacing login with the actual login (anemet).
- The latest tag is prohibited in the docker-compose.yml file.
- No password must be present in the docker-compose.yml file.
- It is mandatory to use environment variables to set passwords.
- It is mandatory to use a .env file to store these environment variables.
- It is recommended to use Docker secrets to store confidential information.
- The NGINX container must be the only entrypoint into the infrastructure via
  HTTPS on port 443 using TLSv1.3 only.

Example diagram of the final architecture:

```
                                                 { www }
                                                    ^
                                                    | (443)
                                                    |
+----------------{ Computer HOST }------------------|---------+
|                                                   |         |
|  +-------------{ Docker network }-----------------|------+  |
|  |                                                V      |  |
|  |  [DB] <--(3306)--> [WordPress] <--(9000)--> [NGINX]   |  |
|  |   ^                        ^                   ^      |  |
|  +---|------------------------|-------------------|------+  |
|      |                        |                   |         |
|      V                        V                   V         |
|  (DB Volume)                 ( WordPress   Volume  )        |
|                                                             |
+-------------------------------------------------------------+

Legend:
- [DB]: MariaDB container
- [WordPress]: WordPress + php-fpm container
- [NGINX]: NGINX container
- (DB Volume): Named volume for MariaDB database
- (WordPress Volume): Named volume for WordPress website files
- { www }: external users accessing the services via HTTPS
- Ports: 443 for HTTPS, 3306 for MariaDB, 9000 for php-fpm
```

Example of the expected directory structure:

```bash
$> ls -alR
total XX
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 .
drwxrwxrwt 17 wil wil 4096 avril 42 20:42 ..
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 Makefile
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 secrets
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 srcs
./secrets:
total XX
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 6 wil wil 4096 avril 42 20:42 ..
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 credentials.txt
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 db_password.txt
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 db_root_password.txt
./srcs:
total XX
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 ..
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 docker-compose.yml
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 .env
drwxrwxr-x 5 wil wil 4096 avril 42 20:42 requirements
./srcs/requirements:
total XX
drwxrwxr-x 5 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 ..
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 bonus
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 mariadb
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 nginx
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 tools
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 wordpress
./srcs/requirements/mariadb:
total XX
drwxrwxr-x 4 wil wil 4096 avril 42 20:45 .
drwxrwxr-x 5 wil wil 4096 avril 42 20:42 ..
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 conf
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 Dockerfile
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 .dockerignore
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 tools
[...]
./srcs/requirements/nginx:
total XX
drwxrwxr-x 4 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 5 wil wil 4096 avril 42 20:42 ..
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 conf
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 Dockerfile
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 .dockerignore
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 tools
[...]
$> cat srcs/.env
DOMAIN_NAME=wil.42.fr
# MYSQL SETUP
MYSQL_USER=XXXXXXXXXXXX
[...]
$>
```

## Readme Requirements

A README.md file is required at the root of the repository.
Its purpose is to allow anyone unfamiliar with the project to quickly understand
what the project is about, how to set it up, and how to use it.
The README.md file must contain at least:
- The very first line must be italicized and read:
  *This project has been created as part of the 42 curriculum by anemet.*
- A **Description** section that clearly presents the project, including its goal and a brief overview.
- An **Instructions** section containing any relevant information about compilation, installation, and/or execution.
- A **Resources** section listing classic references related to the topic (documentation, articles, tutorials, etc.), as well as a description of how AI was used -- specifying for which tasks and which parts of the project were involved.
- A **Project description** section must also explain the use of Docker and the sources included in the project. It must indicate the main design choices, as well as a comparison between:
  - Virtual Machines vs Docker
  - Secrets vs Environment Variables
  - Docker Network vs Host Network
  - Docker Volumes vs Bind Mounts


## Prerequisites for validation

In addition to the existing requirements, the following documentation must be present at the root of the repository. They must be written in `markdown` format.

- USER_DOC.md: **User documentation**. This file must explain in simple terms how an end user or administrator can:
  - Understand what services are provided by the stack
  - Start and stop the project
  - Addess the website and the administration panel
  - Locate and manage credentials
  - Check that the services are running correctly

- DEV_DOC.md: **Developer documentation**. This file must explain in detail how a developer can:
  - Set up the environment from scratch (prerequisites, configuration files, secrets, etc.)
  - Build and launch the project using the Makefile and Docker Compose
  - Use relevant commands to manage the containers and volumes
  - Identify where the project data is stored and how it persists


## Bonus Part

A Dockerfile must be written for each additional service. Thus, each service will run inside its own container and will have, if necessary, its dedicated volume.

Bonus list:
- Set up `redis cache` for the WordPress website in order to properly manage the cache
- Set up `FTP server` container pointing to the volume of the WordPress website
- Create a simple static website in the chosen language (except PHP). For example, a showcase site or a site for presenting your resume.
- Set up `Adminer` (to manage the MariaDB database via a web interface).
- Set up a service of your choice that you find relevant for this infrastructure. During the defense, you will have to justify your choice.
- To complete the bonus part, you have the possibility to set up extra services. In this case, you may open more ports to suit your needs.
