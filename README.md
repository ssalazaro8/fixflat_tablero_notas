# Portal de Equipo - Tablero Compartido de Notas

**Aplicación web empresarial completa** para gestión de actividad de equipo, administración de usuarios y organización colaborativa de notas en tablero interactivo.

---

## 🎯 Características Principales

- **Autenticación segura** con gestión de sesiones
- **Dos roles de usuario**: Administrador y Usuario regular
- **Gestión completa de usuarios**: crear, editar, desactivar (solo admin)
- **Tablero de notas interactivo**:
  - Drag & drop para reorganizar notas
  - Edición en línea (título, texto, estado)
  - Estados: Pendiente, En curso, Hecho
  - Posiciones guardadas automáticamente
- **Dashboard en tiempo real** con métricas
- **Base de datos embebida** (SQLite) - sin dependencias externas
- **Arquitectura AWS** (EC2, Lambda, S3) - lista para producción

---

## 🌐 Acceso a Aplicación Desplegada

**URL en Vivo:**
```
http://3.216.23.20:5000
```

### Credenciales de Acceso

| Rol | Email | Contraseña |
|-----|-------|-----------|
| **Administrador** | `admin@demo.com` | `admin123` |
| **Usuario Regular** | `user@demo.com` | `user123` |

**Nota:** Las credenciales están preconfiguradas en la base de datos embebida y funcionan inmediatamente al desplegar.

---

## ⚡ Inicio Rápido

### Opción 1: Acceso en Línea (Recomendado)

Ingresa directamente a: **http://3.216.23.20:5000**

Usa cualquiera de las credenciales anteriores.

---

### Opción 2: Docker Compose (Local)

**Requisitos**: Docker y Docker Compose

```bash
# Clonar el repositorio
git clone https://github.com/ssalazaro8/fifxflat_-tablero_de_notas.git
cd fifxflat_-tablero_de_notas

# Ejecutar con Docker Compose
docker-compose up --build

# Acceder a la aplicación
Abre tu navegador en: http://localhost:5000
```

---

### Opción 3: Ejecución Local (Python)

**Requisitos**: Python 3.11+, pip

```bash
# Clonar el repositorio
git clone https://github.com/ssalazaro8/fifxflat_-tablero_de_notas.git
cd fifxflat_-tablero_de_notas

# Instalar dependencias
cd src/backend
pip install -r requirements.txt

# Ejecutar la aplicación
python app.py

# Acceder a la aplicación
Abre tu navegador en: http://localhost:5000
```

---

## 📖 Guía de Uso

### Iniciar Sesión
1. Ingresa email y contraseña
2. Haz clic en "Iniciar Sesión"
3. Acceso inmediato al dashboard

### Dashboard
- Visualiza el total de notas
- Distribución de notas por estado
- Métricas actualizadas en tiempo real
- Botón "Actualizar Métricas" para refrescar manualmente

### Tablero de Notas

**Crear una nota:**
1. Haz clic en "+ Nueva Nota"
2. Completa título, texto y estado
3. Haz clic en "Guardar"

**Editar una nota:**
1. Haz clic en el icono ✏️
2. Modifica los campos
3. Haz clic en "Guardar"

**Cambiar estado:**
- Haz clic en el estado de la nota
- Cicla automáticamente: Pendiente → En curso → Hecho

**Mover una nota:**
- Arrastra la nota con el ratón
- La posición se guarda automáticamente al soltar

**Eliminar una nota:**
1. Haz clic en el icono 🗑️
2. Confirma la eliminación

### Gestión de Usuarios (Solo Administrador)

**Ver usuarios:**
- Ve al tab "Gestión de Usuarios"
- Visualiza lista completa

**Crear usuario:**
1. Haz clic en "+ Nuevo Usuario"
2. Completa nombre, email, contraseña y rol
3. Haz clic en "Guardar"

**Editar usuario:**
1. Haz clic en "Editar" en la tarjeta del usuario
2. Modifica datos y estado (activo/inactivo)
3. Haz clic en "Guardar"

---

## 🏗️ Arquitectura

### Infraestructura Desplegada en AWS

```
CloudFormation Stack: team-portal-stack
├── EC2 Instance (t3.micro)
│   ├── Docker Engine
│   ├── Docker Compose
│   └── Aplicación Flask con SQLite
├── Lambda Function
│   └── Dashboard Metrics Calculation
├── S3 Bucket
│   └── Frontend Assets (optional)
├── VPC (10.0.0.0/16)
├── Security Group
│   ├── HTTP (80)
│   ├── HTTPS (443)
│   ├── Puerto 5000 (API)
│   └── SSH (22)
└── IAM Roles & Policies
```

### Arquitectura Local (Desarrollo)

```
Frontend (HTML/CSS/JS) 
    ↓
Backend Flask (Python)
    ↓
SQLite Database
```

---

## 📁 Estructura del Proyecto

```
fixflat/
├── src/
│   ├── backend/
│   │   ├── app.py                 # Aplicación Flask principal
│   │   ├── database.py            # Modelos SQLAlchemy y datos demo
│   │   ├── requirements.txt       # Dependencias Python
│   │   └── static/
│   │       ├── index.html         # Interfaz web
│   │       ├── style.css          # Estilos responsive
│   │       └── script.js          # Lógica del cliente (JavaScript)
│   └── lambda/
│       └── lambda_function.py     # Función AWS Lambda (métricas)
├── Dockerfile                     # Imagen Docker optimizada
├── docker-compose.yaml            # Orquestación de servicios
├── template.yaml                  # Infrastructure as Code (SAM/CloudFormation)
├── deploy-aws.ps1                 # Script de deployment (PowerShell)
├── deploy-aws.sh                  # Script de deployment (Bash)
├── .env                           # Variables de entorno
├── .gitignore                     # Archivos a ignorar
└── README.md                      # Este archivo
```

---

## 🗄️ Base de Datos

### Tipo y Ubicación
- **Motor**: SQLite (embebida, sin servidor externo)
- **Archivo**: `team_portal.db` (creada automáticamente)
- **Ubicación en Docker**: `/data/team_portal.db`
- **Persistencia**: Volúmenes de Docker mantienen datos entre reinicios

### Datos de Demostración
Automáticamente en la primera ejecución:
1. Se crea la base de datos `team_portal.db`
2. Se generan las tablas (usuarios, notas)
3. Se insertan credenciales de demo (admin y usuario)
4. Se agregan 3 notas de ejemplo

### Resetear la Base de Datos

**Con Docker:**
```bash
docker-compose down -v  # Elimina volúmenes
docker-compose up --build  # Crea BD nueva con datos de demo
```

**Local:**
```bash
rm src/backend/team_portal.db
python app.py  # Crea BD nueva con datos de demo
```

---

## ☁️ Despliegue en AWS

### Requisitos Previos

1. **Cuenta AWS** (Free Tier)
2. **AWS CLI** instalado y configurado
3. **SAM CLI** (Serverless Application Model)
4. **Docker** para el build local
5. **Credenciales AWS** configuradas

### Costos (AWS Free Tier)

| Servicio | Uso | Costo |
|----------|-----|--------|
| **EC2 t3.micro** | 750 horas/mes | 🟢 GRATIS (12 meses) |
| **Lambda** | 1M requests/mes | 🟢 GRATIS (siempre) |
| **S3** | 5 GB almacenamiento | 🟢 GRATIS (12 meses) |

**Total: $0.00 durante 12 meses**

### Stack Desplegado

```
Stack Name: team-portal-stack
Status: CREATE_COMPLETE
Region: us-east-1
```

---

## 🔒 Seguridad

### Desarrollo
- Sesiones de Flask (secure cookies)
- CORS habilitado para localhost
- Password hashing con Werkzeug

### Producción
- Security Groups restringen acceso
- IAM roles con permisos mínimos
- HTTPS recommended (configurar con load balancer)

---

## 📝 API Endpoints

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/me` - Usuario actual

### Notas
- `GET /api/notes` - Listar todas las notas
- `POST /api/notes` - Crear nueva nota
- `PUT /api/notes/<id>` - Actualizar nota
- `DELETE /api/notes/<id>` - Eliminar nota

### Dashboard
- `GET /api/dashboard/metrics` - Obtener métricas (total, distribución)

### Usuarios (Admin)
- `GET /api/users` - Listar usuarios
- `POST /api/users` - Crear usuario
- `PUT /api/users/<id>` - Actualizar usuario

---

## 🛠️ Tecnologías Utilizadas

### Backend
- **Framework**: Flask (Python 3.11)
- **Base de Datos**: SQLite
- **ORM**: SQLAlchemy
- **Autenticación**: Flask Sessions
- **Seguridad**: Werkzeug (password hashing)

### Frontend
- **HTML5** - Estructura
- **CSS3** - Estilos responsive
- **Vanilla JavaScript** - Interactividad
- **Drag & Drop API** - Reordenamiento de notas

### Infraestructura
- **Containerización**: Docker, Docker Compose
- **Cloud**: AWS (EC2, Lambda, S3)
- **Infrastructure as Code**: AWS CloudFormation (SAM)

---

## ✅ Requisitos de Prueba Técnica - Cumplimiento

### 1. Acceso y Usuarios ✅
- [x] Login/logout funcional
- [x] 2 roles: Administrador y Usuario
- [x] Gestión CRUD de usuarios
- [x] Cuentas de demostración preconfiguradas
- [x] Al menos un administrador siempre activo

### 2. Tablero Compartido de Notas ✅
- [x] Lienzo libre con notas tipo post-it
- [x] Crear, editar, eliminar notas
- [x] Estados: Pendiente, En curso, Hecho
- [x] Drag & drop funcional
- [x] Posiciones guardadas automáticamente
- [x] Persistencia en base de datos

### 3. Dashboard ✅
- [x] Total de notas
- [x] Distribución por estado
- [x] Métricas en tiempo real
- [x] AWS Lambda para cálculo de métricas

### 4. Ejecución Local y Arquitectura AWS ✅
- [x] Ejecutable en local (Docker Compose)
- [x] Dockerfiles optimizados
- [x] Instrucciones para levantar el entorno
- [x] Datos de demostración automáticos
- [x] **AWS Stack desplegado y funcional**
- [x] EC2 instance en ejecución
- [x] Lambda function incluida
- [x] S3 configurado
- [x] Infrastructure as Code (CloudFormation)
- [x] Scripts de deployment


---

## 🐛 Solución de Problemas

### Puerto 5000 en uso (Local)
```bash
# Opción 1: Cambiar puerto en docker-compose.yaml
# Cambiar: "5000:5000" → "8000:5000"

# Opción 2: Liberar puerto
# Windows: netstat -ano | findstr :5000
# Linux/Mac: lsof -i :5000
```

### La base de datos no se crea
```bash
# Con Docker
docker-compose down
docker-compose up --build

# Local
rm src/backend/team_portal.db
python app.py
```

### Error de conexión en aplicación desplegada
El JavaScript utiliza `${window.location.origin}/api` para conectarse dinámicamente al backend, permitiendo funcionamiento tanto en local como en AWS.

---

## 📚 Documentación Adicional

### Cambiar credenciales de demo
Edita `src/backend/database.py` en la función `init_db()`:

```python
admin = User(
    name='Tu Nombre',
    email='tu-email@ejemplo.com',
    password_hash=generate_password_hash('tu-password'),
    ...
)
```

### Variables de entorno
Edita `.env` para personalizar:
```
FLASK_ENV=development  # O 'production'
SECRET_KEY=tu-clave-secreta
DATABASE_URL=sqlite:///team_portal.db
PORT=5000
```

---

## 📄 Licencia

Proyecto de prueba técnica. Disponible para revisión y evaluación.

---

**Versión**: 1.0.0  
**Estado**: ✅ Producción  
**Última actualización**: 2026-09-17

**GitHub**: https://github.com/ssalazaro8/fifxflat_-tablero_de_notas
