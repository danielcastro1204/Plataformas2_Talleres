#!/bin/bash
set -e

echo "=== Instalando dependencias base ==="
apt-get update -y
apt-get install -y ca-certificates curl gnupg git

echo "=== Instalando Docker ==="
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  usermod -aG docker vagrant
fi

echo "=== Clonando repositorio ==="
cd /home/vagrant
if [ ! -d "microservice-app-example" ]; then
  git clone https://github.com/bortizf/microservice-app-example.git
fi

cd microservice-app-example/log-message-processor

echo "=== Construyendo imagen Docker ==="
docker build -t log-message-processor:latest .

echo "=== Levantando contenedor ==="
docker rm -f log-message-processor || true

docker run -d \
  --name log-message-processor \
  -e REDIS_HOST=192.168.56.15 \
  -e REDIS_PORT=6379 \
  -e REDIS_CHANNEL=log_channel \
  log-message-processor:latest