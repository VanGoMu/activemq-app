# ActiveMQ Docker Compose

Este proyecto proporciona un entorno Docker Compose para desplegar Apache ActiveMQ de forma sencilla.

## 📋 Requisitos previos

- Docker Engine 20.10 o superior
- Docker Compose 2.0 o superior

## 🚀 Inicio rápido

1. **Clonar el repositorio** (si aún no lo has hecho):
   ```bash
   git clone <repository-url>
   cd activemq-app
   ```

2. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env
   ```
   
   Edita el archivo `.env` según tus necesidades.

3. **Iniciar ActiveMQ**:
   ```bash
   docker-compose up -d
   ```

4. **Verificar el estado**:
   ```bash
   docker-compose ps
   ```

## 🌐 Acceso

Una vez iniciado, puedes acceder a:

- **Consola Web**: http://localhost:8161/admin
  - Usuario por defecto: `admin`
  - Contraseña por defecto: `admin`

## 🔌 Protocolos y puertos

ActiveMQ expone los siguientes puertos por defecto:

| Protocolo | Puerto | Descripción |
|-----------|--------|-------------|
| Web Console | 8161 | Interfaz web de administración |
| OpenWire | 61616 | Protocolo nativo de ActiveMQ |
| AMQP | 5672 | Advanced Message Queuing Protocol |
| STOMP | 61613 | Simple Text Oriented Messaging Protocol |
| MQTT | 1883 | Message Queuing Telemetry Transport |
| WebSocket | 61614 | WebSocket para mensajería en tiempo real |

## ⚙️ Configuración

### Variables de entorno

Puedes personalizar la configuración editando el archivo `.env`:

```bash
# Puertos
ACTIVEMQ_WEB_PORT=8161
ACTIVEMQ_OPENWIRE_PORT=61616
ACTIVEMQ_AMQP_PORT=5672
ACTIVEMQ_STOMP_PORT=61613
ACTIVEMQ_MQTT_PORT=1883
ACTIVEMQ_WS_PORT=61614

# Credenciales
ACTIVEMQ_ADMIN_LOGIN=admin
ACTIVEMQ_ADMIN_PASSWORD=admin

# Memoria (MB)
ACTIVEMQ_MIN_MEMORY=512
ACTIVEMQ_MAX_MEMORY=2048
```

### Configuración personalizada de ActiveMQ

Si necesitas una configuración personalizada:

1. Crea un directorio `config`:
   ```bash
   mkdir config
   ```

2. Extrae la configuración por defecto del contenedor:
   ```bash
   docker-compose up -d
   docker cp activemq:/opt/apache-activemq/conf/activemq.xml ./config/
   docker-compose down
   ```

3. Edita `config/activemq.xml` según tus necesidades

4. Descomenta la siguiente línea en `docker-compose.yml`:
   ```yaml
   # - ./config/activemq.xml:/opt/apache-activemq/conf/activemq.xml
   ```

5. Reinicia el contenedor:
   ```bash
   docker-compose up -d
   ```

## 📊 Comandos útiles

### Iniciar servicios
```bash
docker-compose up -d
```

### Detener servicios
```bash
docker-compose down
```

### Ver logs
```bash
docker-compose logs -f activemq
```

### Reiniciar servicios
```bash
docker-compose restart
```

### Ver estado de los servicios
```bash
docker-compose ps
```

### Ejecutar comandos dentro del contenedor
```bash
docker-compose exec activemq bash
```

### Eliminar todo (incluyendo volúmenes)
```bash
docker-compose down -v
```

## 💾 Persistencia de datos

Los datos de ActiveMQ se persisten en volúmenes Docker:

- `activemq-data`: Datos de mensajes y configuración
- `activemq-logs`: Archivos de log

Para hacer backup de los datos:
```bash
docker run --rm -v activemq-app_activemq-data:/data -v $(pwd):/backup alpine tar czf /backup/activemq-backup.tar.gz -C /data .
```

Para restaurar desde backup:
```bash
docker run --rm -v activemq-app_activemq-data:/data -v $(pwd):/backup alpine tar xzf /backup/activemq-backup.tar.gz -C /data
```

## 🔍 Healthcheck

El servicio incluye un healthcheck que verifica cada 30 segundos que ActiveMQ esté respondiendo correctamente.

## 🔒 Seguridad

⚠️ **IMPORTANTE**: Por defecto, el usuario y contraseña son `admin/admin`. 

Para producción:
1. Cambia las credenciales en el archivo `.env`
2. Considera usar Docker secrets
3. Configura SSL/TLS para las conexiones
4. Limita el acceso a los puertos mediante firewall

## 🐛 Solución de problemas

### El contenedor no inicia
```bash
docker-compose logs activemq
```

### Comprobar el healthcheck
```bash
docker inspect activemq | grep -A 10 Health
```

### Resetear completamente
```bash
docker-compose down -v
docker-compose up -d
```

## 📚 Documentación adicional

- [Documentación oficial de ActiveMQ](https://activemq.apache.org/components/classic/)
- [Docker Hub - Apache ActiveMQ](https://hub.docker.com/r/apache/activemq-classic)

## 🐳 How to run all services with Docker Compose

1. Build and start all services:
   ```sh
   cd docker
   docker compose up --build -d
   ```

2. Services started:
   - **ActiveMQ**: Message broker (web console at http://localhost:8161/admin)
   - **fastapi-app**: HTTP API to send messages to ActiveMQ (http://localhost:8000)
   - **fastapi-consumer1**: Consumer service (http://localhost:8001)
   - **fastapi-consumer2**: Consumer service (http://localhost:8002)

3. Send a message to the queue:
   ```sh
   curl -X POST http://localhost:8000/send -H "Content-Type: application/json" -d '{"body": "Hello from FastAPI!"}'
   ```

4. Consume messages (alternating between consumers):
   ```sh
   curl http://localhost:8001/consume
   curl http://localhost:8002/consume
   ```
   Each consumer will show its identifier and the message content.

5. Stop all services:
   ```sh
   docker compose down
   ```

## 📊 Logging, Monitoring & Kibana Integration

This project includes full logging and monitoring with the ELK stack (Elasticsearch, Logstash, Kibana) and Filebeat.

### How it works
- All FastAPI apps log requests and events in JSON format to `/app/logs/app.log`.
- Filebeat collects logs from all apps and sends them to Elasticsearch.
- Kibana provides dashboards and search for all logs and events.

### How to use
1. Build and start all services:
   ```sh
   cd docker
   docker compose up --build -d
   ```
2. Access Kibana:
   - URL: [http://localhost:5601](http://localhost:5601)
   - Default index: filebeat-*
   - Search, filter, and create dashboards for all FastAPI events.
3. All logs are stored in Elasticsearch and visible in Kibana.

### How logging is implemented
- Each FastAPI app uses `json-log-formatter` to write logs in JSON format.
- Logs are written to `/app/logs/app.log` (mounted as a Docker volume).
- Example log entry:
  ```json
  {
    "event": "message_sent",
    "queue": "/queue/test.queue",
    "body": "Hello from FastAPI!",
    "client": "172.18.0.1"
  }
  ```
- Filebeat is configured to read logs from all apps and send them to Elasticsearch.

### How to extend
- You can add more fields to logs (user, endpoint, status, etc).
- You can create custom dashboards in Kibana for API usage, errors, performance, etc.

### Troubleshooting
- If logs do not appear in Kibana, check Filebeat and Elasticsearch containers for errors.
- Make sure the log files are being written and mounted correctly.

## 📝 Notes
- You can scale consumers by adding more services in `docker-compose.yml` with different `SERVICE_ID` and ports.
- All services are connected via the same Docker network for easy communication.
- Environment variables can be customized in the compose file or `.env` files.

## 📝 Licencia

Ver archivo [LICENSE](LICENSE)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request.
