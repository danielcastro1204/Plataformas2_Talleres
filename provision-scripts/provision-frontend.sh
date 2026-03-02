#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> provision-frontend: inicio"

# 1) paquetes básicos
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# 2) instalar Docker si no existe
if ! command -v docker >/dev/null 2>&1; then
  echo ">>> installing Docker..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
fi

# permitir a vagrant usar docker sin sudo
sudo usermod -aG docker vagrant || true

# Esperar a que docker esté operativo
COUNTER=0
until sudo docker info >/dev/null 2>&1 || [ $COUNTER -ge 20 ]; do
  sleep 1
  COUNTER=$((COUNTER+1))
done
if ! sudo docker info >/dev/null 2>&1; then
  echo "ERROR: Docker no arrancó en el tiempo esperado"
  exit 1
fi

# 3) clonar repo (si no existe) o actualizarlo
REPO="https://github.com/bortizf/microservice-app-example.git"
BASE_DIR="/home/vagrant/microservice-app-example"
SERVICE_DIR="${BASE_DIR}/frontend"
IMAGE_NAME="frontend:latest"
CONTAINER_NAME="frontend"

if [ ! -d "$BASE_DIR" ]; then
  echo ">>> Clonando repo..."
  git clone "$REPO" "$BASE_DIR"
else
  echo ">>> Repo ya existe: actualizando..."
  cd "$BASE_DIR" && git pull || true
fi

# 4) verificar carpeta del servicio
if [ ! -d "$SERVICE_DIR" ]; then
  echo "ERROR: no se encontró $SERVICE_DIR. Revisa la estructura del repo."
  exit 1
fi

cd "$SERVICE_DIR"

# 5) Si no hay Dockerfile, crear uno compatible con las instrucciones (Node 8)
if [ ! -f Dockerfile ]; then
  echo ">>> No existe Dockerfile en frontend: creando Dockerfile por defecto (node:8.17.0)"
  sudo tee Dockerfile > /dev/null <<'EOF'
# Dockerfile para frontend (construye la UI y ejecuta el dev server)
FROM node:8.17.0

WORKDIR /app

# Copiar package.json e instalar deps (separado para cache)
COPY package*.json ./
RUN npm install --production || npm install

# Copiar el resto del código
COPY . .

# Build de la aplicación (genera build en build/dist según repo)
RUN npm run build

# Puerto por defecto que usa el dev-server (el start usa build/dev-server.js)
ENV PORT=8080
EXPOSE 8080

# VARIABLES RELEVANTES:
# AUTH_API_ADDRESS - dirección del auth-api
# TODOS_API_ADDRESS - dirección del todos-api
CMD ["sh", "-c", "PORT=${PORT} AUTH_API_ADDRESS=${AUTH_API_ADDRESS:-http://127.0.0.1:8000} TODOS_API_ADDRESS=${TODOS_API_ADDRESS:-http://127.0.0.1:8082} npm start"]
EOF
else
  echo ">>> Dockerfile ya presente en frontend; se usará el existente."
fi

# 6) Construir la imagen
echo ">>> Construyendo imagen docker: ${IMAGE_NAME}"
sudo docker build -t ${IMAGE_NAME} .

# 7) Arrancar el contenedor (variables por defecto; puedes modificarlas)
# Valores por defecto (apuntan a localhost/puertos de ejemplo):
DEFAULT_PORT=8080
DEFAULT_AUTH="http://127.0.0.1:8000"
DEFAULT_TODOS="http://127.0.0.1:8082"

sudo docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
sudo docker run -d \
  --name ${CONTAINER_NAME} \
  -p ${DEFAULT_PORT}:8080 \
  -e PORT=${DEFAULT_PORT} \
  -e AUTH_API_ADDRESS=${DEFAULT_AUTH} \
  -e TODOS_API_ADDRESS=${DEFAULT_TODOS} \
  --restart unless-stopped \
  ${IMAGE_NAME}

echo ">>> provision-frontend: hecho. Frontend corriendo en 192.168.56.11:${DEFAULT_PORT} dentro de la red privada"