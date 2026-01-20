# srcs/requirements/redis/Dockerfile
FROM debian:bullseye

# Install Redis
RUN apt-get update && apt-get install -y redis-server

# Configure Redis to listen on all interfaces (0.0.0.0) instead of just localhost
# and disable protected mode so other containers can connect.
RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis/redis.conf && \
    sed -i "s|# maxmemory <bytes>|maxmemory 256mb|g" /etc/redis/redis.conf && \
    sed -i "s|# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g" /etc/redis/redis.conf

# Expose the standard Redis port
EXPOSE 6379

# Run Redis in the foreground with protected mode off
CMD ["redis-server", "--protected-mode", "no"]
