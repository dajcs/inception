# srcs/requirements/ftp/Dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y vsftpd

# Copy the startup script
COPY tools/ftp.sh /usr/local/bin/ftp.sh
RUN chmod +x /usr/local/bin/ftp.sh

# Create the folder required by vsftpd for secure chrooting
RUN mkdir -p /var/run/vsftpd/empty

# Expose FTP Command port (21) and Passive Data ports (21100-21110)
EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/ftp.sh"]
