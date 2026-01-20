FROM debian:bullseye

# 1. Install wget and tar to download the binary
RUN apt-get update && apt-get install -y \
    wget \
    tar

# 2. Download the latest Portainer binary
RUN wget https://github.com/portainer/portainer/releases/download/2.33.6/portainer-2.33.6-linux-amd64.tar.gz

# 3. Extract it
RUN tar -xvf portainer-2.33.6-linux-amd64.tar.gz -C /usr/local/bin/

# 4. Clean up
RUN rm -rf portainer-2.33.6-linux-amd64.tar.gz

# 5. Create data directory
RUN mkdir -p /data

# 6. Copy and run script
COPY tools/portainer.sh /usr/local/bin/portainer.sh
RUN chmod +x /usr/local/bin/portainer.sh

# Expose Portainer port
EXPOSE 9000

CMD ["/usr/local/bin/portainer.sh"]
