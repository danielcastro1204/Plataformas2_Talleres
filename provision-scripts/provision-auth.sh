#!/bin/bash
set -e

echo "=== Provision AUTH API ==="

# Update
sudo apt update -y
sudo apt install -y git curl

# -------------------------
# Install Go 1.18.2
# -------------------------
if ! command -v go &> /dev/null; then
  echo "Installing Go 1.18.2"
  wget -q https://go.dev/dl/go1.18.2.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
fi

# Go PATH
if ! grep -q "/usr/local/go/bin" /home/vagrant/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bashrc
fi

export PATH=$PATH:/usr/local/go/bin
export GO111MODULE=on

# -------------------------
# Clone repo if not exists
# -------------------------
cd /home/vagrant

if [ ! -d "microservice-app-example" ]; then
  git clone https://github.com/bortizf/microservice-app-example.git
fi

cd microservice-app-example/auth-api

# -------------------------
# Go modules
# -------------------------
if [ ! -f "go.mod" ]; then
  go mod init auth-api
fi

go mod tidy

# -------------------------
# Build
# -------------------------
go build -o auth-api

echo "=== AUTH API provisioned successfully ==="