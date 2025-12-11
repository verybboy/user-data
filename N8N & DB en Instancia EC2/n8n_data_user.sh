#!/bin/bash
# =======================================
#   Instalación automática de n8n en EC2
#   Ubuntu 22.04 / 24.04
# =======================================

# --- Actualizar repos ---
apt-get update -y
apt-get upgrade -y

# --- Instalar dependencias ---
apt-get install -y ca-certificates curl gnupg

# --- Añadir repositorio oficial de Docker ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update -y

# --- Instalar Docker y Docker Compose ---
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Habilitar Docker ---
systemctl enable docker
systemctl start docker

# --- Crear carpeta de n8n ---
mkdir -p /opt/n8n
cd /opt/n8n

# --- Crear archivo .env ---
cat << 'EOF' > /opt/n8n/.env
POSTGRES_USER=n8n
POSTGRES_PASSWORD=CHANGEME
POSTGRES_DB=n8n

N8N_PORT=5678
N8N_HOST=$(curl -s ifconfig.me)
N8N_PROTOCOL=http

GENERIC_TIMEZONE=Europe/Madrid
N8N_ENCRYPTION_KEY=CHANGEME
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=CHANGEME
N8N_SECURE_COOKIE=false
EOF

# --- Crear docker-compose.yml ---
cat << 'EOF' > /opt/n8n/docker-compose.yml
services:
  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - n8n_postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}

      - N8N_PORT=${N8N_PORT}
      - N8N_HOST=${N8N_HOST}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}

      - N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}

      - N8N_SECURE_COOKIE=${N8N_SECURE_COOKIE}

    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_postgres_data:
  n8n_data:
EOF

# --- Arrancar n8n automáticamente ---
docker compose -f /opt/n8n/docker-compose.yml pull
docker compose -f /opt/n8n/docker-compose.yml up -d

# --- FIN ---
