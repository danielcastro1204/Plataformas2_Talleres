#!/usr/bin/env bash
set -euo pipefail

echo ">>> provision-haproxy: instalando haproxy"
sudo apt-get update -y
sudo apt-get install -y haproxy

if [ ! -f /vagrant/provision-scripts/haproxy.cfg ]; then
  echo "ERROR: /vagrant/provision-scripts/haproxy.cfg no encontrado en el host. Crea ese archivo y reprovisiona."
  exit 1
fi

sudo cp /vagrant/provision-scripts/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl enable haproxy
sudo systemctl restart haproxy

echo ">>> provision-haproxy: haproxy configurado"