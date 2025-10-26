#!/bin/zsh
# Script para iniciar ActiveMQ con Docker Compose

set -e

# Navigate to root directory
COMPOSE_FILE="docker/docker-compose.yml"
ENV_FILE="docker/.env"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: No se encontró $COMPOSE_FILE"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Advertencia: No se encontró $ENV_FILE. Usando variables por defecto."
else
  echo "Usando variables de entorno de $ENV_FILE."
fi

# Iniciar ActiveMQ

echo "Iniciando ActiveMQ..."
docker compose -f "$COMPOSE_FILE" up -d --build

echo "ActiveMQ iniciado. Accede a la consola web en http://localhost:8161/admin"
