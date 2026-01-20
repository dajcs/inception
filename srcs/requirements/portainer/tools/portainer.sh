#!/bin/bash

# Portainer is a binary, so we just launch it.
# -H : connects to the local docker socket
exec /usr/local/bin/portainer/portainer
