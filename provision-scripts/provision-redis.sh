#!/usr/bin/env bash
set -euo pipefail

echo ">>> provision-redis: arrancando redis en docker"
sudo docker rm -f redis 2>/dev/null || true
sudo docker run -d --name redis --restart unless-stopped -p 6379:6379 redis:7
echo ">>> provision-redis: redis corriendo (puerto 6379)"