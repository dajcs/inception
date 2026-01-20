FROM debian:bullseye

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy Nginx config
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Create the specific directory for the route
RUN mkdir -p /var/www/html/cv

# Copy Website files into the /cv subdirectory
COPY tools/ /var/www/html/cv/

# Expose port 80 (Internal)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
