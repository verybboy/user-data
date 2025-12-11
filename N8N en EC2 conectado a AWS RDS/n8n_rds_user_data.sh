#!/bin/bash
# =======================================
#   n8n + RDS PostgreSQL on EC2 (User Data)
#   Versión con RDS, SSL y configuración de n8n
#   Estilo clásico (sin set -eux / sin modo estricto)
# =======================================

# --- Actualizar índices y paquetes ---
apt-get update -y
apt-get upgrade -y

# --- Instalar dependencias ---
apt-get install -y ca-certificates curl gnupg

# --- Añadir repositorio Docker ---
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

. /etc/os-release
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y

# --- Instalar Docker ---
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Habilitar Docker ---
systemctl enable docker
systemctl start docker

# --- Permitir que ubuntu use docker ---
usermod -aG docker ubuntu || true

# --- Crear carpeta n8n ---
mkdir -p /opt/n8n
cd /opt/n8n

# =======================================
#   Crear archivo .env
# =======================================
cat << 'EOF' > /opt/n8n/.env
DB_HOST=TU_ENDPOINT_RDS
DB_PORT=5432
DB_DATABASE=n8n_db
DB_USER=n8n_db_user
DB_PASSWORD=TUPASSWORDRDS

# SSL necesario para RDS
DB_POSTGRESDB_SSL=true
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false

# Configuración n8n
N8N_PORT=5678
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http
GENERIC_TIMEZONE=Europe/Madrid
N8N_ENCRYPTION_KEY=CLAVELARGAUNICA

# Login web
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=CAMBIA_ESTO
N8N_SECURE_COOKIE=false

# Seguridad futura en config
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
EOF

# =======================================
#   Crear docker-compose.yml
# =======================================
cat << 'EOF' > /opt/n8n/docker-compose.yml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    env_file:
      - .env
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=${DB_HOST}
      - DB_POSTGRESDB_PORT=${DB_PORT}
      - DB_POSTGRESDB_DATABASE=${DB_DATABASE}
      - DB_POSTGRESDB_USER=${DB_USER}
      - DB_POSTGRESDB_PASSWORD=${DB_PASSWORD}
      - DB_POSTGRESDB_SSL=${DB_POSTGRESDB_SSL}
      - DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=${DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED}

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
  n8n_data:
EOF

# --- Arrancar n8n ---
docker compose -f /opt/n8n/docker-compose.yml pull || true
docker compose -f /opt/n8n/docker-compose.yml up -d || true

# =======================================
#   FIN
# =======================================