#!/bin/bash

# srcs/requirements/ftp/tools/ftp.sh

if [ -z "$FTP_USER" ] || [ -z "$FTP_PASSWORD" ]; then
    echo "FTP_USER and FTP_PASSWORD must be set in .env"
    exit 1
fi

# 1. Create the FTP user if it doesn't exist
# We set the home directory to /var/www/html so they land in the WP folder
if ! id "$FTP_USER" &>/dev/null; then
    adduser "$FTP_USER" --disabled-password --gecos "" --home /var/www/html --shell /bin/bash
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    
    # Add the user to the vsftpd userlist
    echo "$FTP_USER" | tee -a /etc/vsftpd.userlist
fi

# 2. Add the FTP user to the www-data group (so they can modify WP files)
usermod -aG www-data $FTP_USER
# Ensure the folder belongs to www-data (in case it reset)
chown -R www-data:www-data /var/www/html

# 3. Configure vsftpd.conf dynamically
# We overwrite the default config to ensure settings are correct for Docker
cat << EOF > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
# Enable the userlist
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

# PASSIVE MODE CONFIGURATION (Crucial for Docker)
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
# Allow writing to the root inside chroot (needed because root is /var/www/html)
allow_writeable_chroot=YES
EOF

echo "FTP Server started on port 21"

# 4. Start vsftpd
# We point to the config file we just wrote
exec /usr/sbin/vsftpd /etc/vsftpd.conf
