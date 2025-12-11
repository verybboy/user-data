# Script de Instalación de n8n (User Data)

Este repositorio contiene el archivo `n8n_data_user.sh`, un script de *User Data* diseñado para automatizar la instalación y despliegue de **n8n** junto con su base de datos **PostgreSQL** (alojada en la misma instancia) utilizando Docker en instancias EC2 de Ubuntu (22.04 / 24.04).

## ⚠️ Cambios Obligatorios de Seguridad

Antes de utilizar este script para lanzar una instancia, **es crítico que modifiques las siguientes variables** dentro del archivo `n8n_data_user.sh` para asegurar tu instalación:

1.  **Contraseña de la Base de Datos:**
    - Busca `POSTGRES_PASSWORD=CHANGEME` y reemplaza `CHANGEME` por una contraseña segura.
2.  **Clave de Encriptación de n8n:**
    - Busca `N8N_ENCRYPTION_KEY=CHANGEME` y reemplaza `CHANGEME` por una clave única y segura.
3.  **Contraseña de Acceso Web (Basic Auth):**
    - Busca `N8N_BASIC_AUTH_PASSWORD=CHANGEME` y reemplaza `CHANGEME`.
    - El usuario por defecto es `admin`.

> **Nota:** Si la instancia ya ha sido iniciada, estos valores se envuelcan en el archivo `/opt/n8n/.env` dentro del servidor. Modificarlos allí requerirá reiniciar los contenedores (`docker compose down && docker compose up -d`).

## 🚀 Acceso a n8n

Una vez que la instancia se haya iniciado correctamente y el script haya terminado de ejecutarse (puede tardar unos minutos en completar la instalación de Docker y descargar las imágenes):

1.  **URL de Acceso:**
    - Abre tu navegador y navega a: `http://<TU_IP_PUBLICA>:5678`
    - Sustituye `<TU_IP_PUBLICA>` por la dirección IP pública de tu instancia EC2.

2.  **Autenticación:**
    - Se te solicitarán credenciales de acceso (Basic Auth).
    - **Usuario:** `admin` (o el que hayas configurado en `N8N_BASIC_AUTH_USER`).
    - **Contraseña:** La que hayas definido en `N8N_BASIC_AUTH_PASSWORD`.
