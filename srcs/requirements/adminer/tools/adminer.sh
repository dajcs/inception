#!/bin/bash

# 1. Create the installation directory matching the URL path (/adminer)
mkdir -p /var/www/html/adminer

# 2. Download Adminer if it doesn't exist
# We rename it to index.php so it loads automatically when opening the folder
if [ ! -f /var/www/html/adminer/index.php ]; then
    echo "Downloading Adminer..."
    wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/adminer/index.php
fi

# 3. Adjust ownership
chown -R www-data:www-data /var/www/html/adminer

# 4. Start the PHP built-in web server on port 8080
# -S : Start server
# -t : Root directory
echo "Starting Adminer on port 8080..."
exec php -S 0.0.0.0:8080 -t /var/www/html