#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> provision-common: apt update"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# instalar Docker si no existe
if ! command -v docker >/dev/null 2>&1; then
  echo ">>> provision-common: instalando Docker (get.docker.com)"
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
fi

# permitir al usuario vagrant usar docker sin sudo
sudo usermod -aG docker vagrant || true

# instalar docker-compose por pip si no existe (versión legacy)
if ! command -v docker-compose >/dev/null 2>&1; then
  sudo apt-get install -y python3-pip
  sudo pip3 install docker-compose==1.29.2 || true
fi

# esperar a que docker responda
echo ">>> provision-common: esperando a que docker responda"
COUNTER=0
until sudo docker info >/dev/null 2>&1 || [ $COUNTER -ge 20 ]; do
  sleep 1
  COUNTER=$((COUNTER+1))
done

if ! sudo docker info >/dev/null 2>&1; then
  echo "ERROR: Docker no arrancó en el tiempo esperado"
  exit 1
fi

echo ">>> provision-common: listo"