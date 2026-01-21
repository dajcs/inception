# Bind Mounts vs Named Volumes in Docker Compose

Explaining the difference between Bind Mounts and Named Volumes in Docker Compose, and how to configure a Named Volume to point to a specific host path.

### 1. The Distinction

The subject forbids **Bind Mounts** but requires **Named Volumes** that point to a **specific host path**.

#### What is forbidden (Bind Mount):
A Bind Mount is when you map the path directly inside the `services` section.
```yaml
# ❌ FORBIDDEN
services:
  mariadb:
    volumes:
      - /home/anemet/data/mariadb:/var/lib/mysql
```
If you do this, Docker says "I am taking this folder and sticking it into the container."

#### What is required (Named Volume):
You must use a name (alias) in the `services` section.
```yaml
# ✅ REQUIRED
services:
  mariadb:
    volumes:
      - mariadb_data:/var/lib/mysql
```
Here, the container only knows "I am using a volume named `mariadb_data`." It doesn't know where that data actually lives.

### 2. The "Hack" for the specific path

Standard Docker Named Volumes live in `/var/lib/docker/volumes/...`.
However, the subject **also** requires the data to be in `/home/login/data/`.

To force a **Named Volume** to look at a specific folder instead of its default location, we use the `driver_opts` configuration in the top-level `volumes` section:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind   <-- This is an option for the DRIVER, not the Container
      device: /home/anemet/data/mariadb
```

**Why is `o: bind` allowed here?**
*   **Context:** This `bind` creates a Linux mount point for the *Volume system*, not for the *Container*.
*   **Abstraction:** The Container interacts with a "Named Volume". The Container does not know it is a bind mount. To the container, it is a Volume. Docker acts as the middleman.
*   **The Subject:** The rule "Bind mounts are not allowed" refers to the **Service** configuration, not the **Volume Driver** implementation details.

### 3. How to verify this (for your defense/grading)

When you are evaluated, your corrector will run `docker inspect`.

**If you use the Forbidden method (Service Bind Mount):**
```bash
docker inspect mariadb
# "Mounts": [
#    {
#        "Type": "bind",   <-- THIS IS FAIL
#        "Source": "/home/anemet/data/mariadb",
#        ...
#    }
# ]
```

**If you use my method (Named Volume with driver opts):**
```bash
docker inspect mariadb
# "Mounts": [
#    {
#        "Type": "volume",   <-- THIS IS PASS
#        "Name": "mariadb_data",
#        "Source": "/var/lib/docker/volumes/mariadb_data/_data",
#        ...
#    }
# ]
```

Because the `Type` is **volume**, you satisfy the "Named Volume" requirement. The fact that the volume driver internally binds to a specific folder using `driver_opts` is the correct technical solution to satisfy the second requirement (storage location).
