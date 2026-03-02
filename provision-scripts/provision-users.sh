#!/bin/bash
set -e

echo ">>> Provision USERS API"

apt update

# Java 8
apt install -y openjdk-8-jdk

# Curl + git
apt install -y git curl

# Docker
apt install -y docker.io
usermod -aG docker vagrant

# Clonar repo
cd /home/vagrant
if [ ! -d "microservice-app-example" ]; then
  git clone https://github.com/bortizf/microservice-app-example.git
fi

chown -R vagrant:vagrant /home/vagrant/microservice-app-example