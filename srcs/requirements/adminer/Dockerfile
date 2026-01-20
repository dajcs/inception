FROM debian:bullseye

# 1. Install PHP and wget
# php-mysql is crucial to connect to MariaDB
RUN apt-get update && apt-get install -y \
    wget \
    php7.4 \
    php7.4-mysql

# 2. Copy the startup script
COPY tools/adminer.sh /usr/local/bin/adminer.sh
RUN chmod +x /usr/local/bin/adminer.sh

# 3. Expose the port (Internal)
EXPOSE 8080

# 4. Start
ENTRYPOINT ["/usr/local/bin/adminer.sh"]