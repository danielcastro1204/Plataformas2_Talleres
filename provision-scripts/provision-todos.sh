#!/bin/bash

set -e

echo "==> Actualizando sistema"
apt-get update -y

echo "==> Instalando dependencias base"
apt-get install -y \
  ca-certificates \
  curl \
  git

echo "==> Instalando Docker"
if ! command -v docker &> /dev/null; then
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
  usermod -aG docker vagrant
fi

echo "==> Instalando Docker Compose (plugin)"
if ! docker compose version &> /dev/null; then
  mkdir -p /usr/local/lib/docker/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v2.25.0/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

echo "==> Clonando repositorio"
cd /home/vagrant
if [ ! -d "microservice-app-example" ]; then
  git clone https://github.com/bortizf/microservice-app-example.git
fi

echo "==> Provisión TODOS API completa"