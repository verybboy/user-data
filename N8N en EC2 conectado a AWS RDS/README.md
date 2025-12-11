# Script de Inicialización: n8n conectado a AWS RDS

Este repositorio contiene el script `n8n_rds_user_data.sh`, diseñado para ser utilizado como **User Data** al lanzar una instancia EC2 (Ubuntu 22.04 / 24.04). Su función es instalar y configurar automáticamente **n8n** utilizando Docker, pero a diferencia de una instalación estándar, **conecta n8n a una base de datos PostgreSQL externa alojada en Amazon RDS**.

## 📋 Requisitos Previos

Antes de lanzar la instancia con este script, asegúrate de tener:

1.  **Instancia RDS PostgreSQL creada** y operativa.
2.  **Security Group de RDS** configurado para aceptar conexiones entrantes desde el Security Group de tu nueva instancia EC2 en el puerto `5432`.
3.  **Base de datos vacía creada** (ej: `n8n_db`) dentro de tu instancia RDS.

## ⚙️ Configuración Obligatoria

Este script es una plantilla. **DEBES MODIFICARLO** antes de pegarlo en la sección de User Data de EC2.

Abre el archivo `n8n_rds_user_data.sh` y localiza/reemplaza las siguientes variables dentro de la sección de creación del archivo `.env`:

### 1. Conexión a Base de Datos (RDS)
Busca y rellena estos valores con los de tu RDS AWS:
```bash
DB_HOST=TU_ENDPOINT_RDS       # Ej: n8n-db.xxxx.us-east-1.rds.amazonaws.com
DB_PORT=5432
DB_DATABASE=n8n_db            # Nombre de la DB creada en RDS
DB_USER=n8n_db_user           # Tu usuario maestro de RDS
DB_PASSWORD=TUPASSWORDRDS     # Tu contraseña de RDS
```

### 2. Seguridad de n8n
Cambia estos valores por cadenas seguras y únicas:
```bash
# Clave maestra de encriptación de credenciales (¡NO LA PIERDAS!)
N8N_ENCRYPTION_KEY=CLAVELARGAUNICA 

# Contraseña para acceder al panel web de n8n
N8N_BASIC_AUTH_PASSWORD=CAMBIA_ESTO
```

> **⚠️ Importante:** La variable `N8N_HOST` está configurada como `0.0.0.0` para asegurar que n8n arranque sin errores de red. Sin embargo, para que los **Webhooks** funcionen correctamente en producción, se recomienda configurar un dominio o Elastic IP, o ajustar `N8N_HOST` para que detecte la IP pública si es necesario.

## 🚀 Despliegue

1.  Copia el contenido modificado de `n8n_rds_user_data.sh`.
2.  Al lanzar tu instancia EC2, pégalo en el campo **Advanced details -> User data**.
3.  Lanza la instancia. La instalación tardará unos minutos.
4.  Accede a `http://<TU_IP_PUBLICA>:5678`.

## 📂 Estructura de Volúmenes

- **Datos de n8n:** Se guardan en el volumen Docker `n8n_data` (persiste tras reinicios).
- **Base de Datos:** Los datos **NO** están en la EC2, están seguros en tu RDS.
