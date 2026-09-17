# Portal de Equipo - Tablero Compartido de Notas

Una aplicación web completa para que un equipo consulte su actividad, administre usuarios y organice notas en un tablero compartido interactivo.

## 🎯 Características Principales

- **Autenticación segura** con gestión de sesiones
- **Dos roles de usuario**: Administrador y Usuario regular
- **Gestión completa de usuarios**: crear, editar, desactivar
- **Tablero de notas interactivo**:
  - Drag & drop para mover notas
  - Edición en línea (título, texto, estado)
  - Estados: Pendiente, En curso, Hecho
  - Posiciones guardadas automáticamente
- **Dashboard en tiempo real** con métricas
- **Base de datos embebida** (SQLite) - sin dependencias externas
- **Totalmente dockerizado** para ejecución en cualquier máquina
- **Arquitectura lista para AWS** (EC2, Lambda, S3, CloudFront)

---

## ⚡ Inicio Rápido (5 minutos)

### Opción 1: Docker Compose (Recomendado)

**Requisitos**: Docker y Docker Compose

```bash
# 1. Clonar el repositorio
git clone https://github.com/ssalazaro8/fixflat_tablero_notas.git
cd fixflat-tablero-notas

# 2. Ejecutar con Docker Compose
docker-compose up --build

# 3. Acceder a la aplicación
 Abre tu navegador en: http://localhost:5000
```

### Opción 2: Ejecución Local (Python)

**Requisitos**: Python 3.11+, pip

```bash
# 1. Clonar el repositorio
git clone https://github.com/ssalazaro8/fixflat_tablero_notas.git
cd fixflat-tablero-notas

# 2. Instalar dependencias
cd src/backend
pip install -r requirements.txt

# 3. Ejecutar la aplicación
python app.py

# 4. Acceder a la aplicación
 Abre tu navegador en: http://localhost:5000
```

---

## 👤 Cuentas de Demostración

Todos los usuarios son preconfigurados en la base de datos embebida. Puedes usarlos inmediatamente:

| Rol | Email | Contraseña |
|-----|-------|-----------|
| **Administrador** | `admin@demo.com` | `admin123` |
| **Usuario** | `user@demo.com` | `user123` |


---

## 📁 Estructura del Proyecto

```
fixflat/
├── src/
│   ├── backend/
│   │   ├── app.py                 # Aplicación Flask principal
│   │   ├── database.py            # Modelos y datos de demo
│   │   ├── requirements.txt       # Dependencias Python
│   │   └── static/
│   │       ├── index.html         # Interfaz web
│   │       ├── style.css          # Estilos (responsive)
│   │       └── script.js          # Lógica del cliente
│   └── lambda/
│       └── lambda_function.py     # Función AWS Lambda
├── Dockerfile                     # Imagen Docker
├── docker-compose.yaml            # Orquestación de servicios
├── template.yaml                  # Infraestructura AWS (SAM)
├── .env                           # Variables de entorno (modificar en producción)
├── .gitignore                     # Archivos a ignorar
└── README.md                      # Este archivo
```

---

## 📖 Guía de Uso

### 1. Iniciar Sesión
1. Ingresa email y contraseña (usa las credenciales de demo)
2. Haz clic en "Iniciar Sesión"

### 2. Dashboard
- Visualiza métricas en tiempo real
- Número total de notas
- Distribución por estado
- Haz clic en "Actualizar Métricas" para refrescar

### 3. Tablero de Notas

**Crear una nota:**
- Haz clic en "+ Nueva Nota"
- Completa título, texto y estado
- Haz clic en "Guardar"

**Editar una nota:**
- Haz clic en el icono ✏️
- Modifica los campos
- Haz clic en "Guardar"

**Cambiar estado:**
- Haz clic en el estado de la nota (Pendiente, En curso, Hecho)
- Cicla automáticamente al siguiente estado

**Mover una nota:**
- Arrastra la nota con el ratón
- La posición se guarda automáticamente al soltar

**Eliminar una nota:**
- Haz clic en el icono 🗑️
- Confirma la eliminación

### 4. Gestión de Usuarios (Solo Admin)

**Ver usuarios:**
- Ve al tab "Gestión de Usuarios"
- Visualiza lista de todos los usuarios

**Crear usuario:**
- Haz clic en "+ Nuevo Usuario"
- Completa nombre, email, contraseña y rol
- Haz clic en "Guardar"

**Editar usuario:**
- Haz clic en "Editar" en la tarjeta del usuario
- Modifica datos y estado (activo/inactivo)
- Haz clic en "Guardar"

---

## 🐳 Docker 

El proyecto incluye:
- `Dockerfile` optimizado con Python 3.11-slim
- `docker-compose.yaml` listo para producción
- Volúmenes persistentes para la base de datos
- Red aislada para los servicios

**Para verificar que Docker funciona:**

```bash
# Ver contenedores en ejecución
docker ps

# Ver logs del servidor
docker-compose logs -f api

# Acceder a la BD desde la terminal
docker-compose exec api sqlite3 team_portal.db "SELECT * FROM users;"
```

**Nota importante**: La BD SQLite (`team_portal.db`) se crea automáticamente en `/data` dentro del contenedor y se persiste en el volumen de Docker. No necesitas hacer nada especial.

---

## 🗄️ Base de Datos

### Tipo y Ubicación
- **Motor**: SQLite (embebida, sin servidor externo)
- **Archivo**: `team_portal.db` (se crea automáticamente)
- **Ubicación en Docker**: `/data/team_portal.db`

### ¿Los datos de demo se incluyen?
✅ **SÍ.** Automáticamente:
1. En la primera ejecución, se crea `team_portal.db`
2. Se generan las tablas (usuarios, notas)
3. Se insertan las credenciales de demo (admin y usuario)
4. Se agregan 3 notas de ejemplo

### Persistencia
- **Local**: Los datos se guardan en `src/backend/team_portal.db`
- **Docker**: Los datos se guardan en el volumen `./data/`
- **Permanencia**: Los datos persisten entre reinicios

### Para resetear la BD
```bash
# Con Docker
docker-compose down -v  # Elimina volúmenes
docker-compose up --build  # Crea BD nueva con datos de demo

# Local
rm src/backend/team_portal.db
python app.py  # Crea BD nueva con datos de demo
```

---

## 🏗️ Arquitectura

### Local (Desarrollo)
```
Frontend (HTML/CSS/JS) → Backend Flask → SQLite
```

### AWS (Producción)
```
CloudFront (CDN) → S3 (Frontend)
           ↓
       API Gateway → EC2 (Backend)
           ↓
       Lambda (Métricas)
           ↓
       RDS/Database
```

La plantilla SAM (`template.yaml`) contiene toda la infraestructura lista para desplegar.

---

## 🔒 Seguridad

### En Desarrollo
- Sesiones de Flask (seguras para desarrollo local)
- CORS habilitado para localhost

---

## 📝 API Endpoints

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/logout` - Cerrar sesión
- `GET /api/auth/me` - Usuario actual

### Notas
- `GET /api/notes` - Listar notas
- `POST /api/notes` - Crear nota
- `PUT /api/notes/<id>` - Actualizar nota
- `DELETE /api/notes/<id>` - Eliminar nota

### Dashboard
- `GET /api/dashboard/metrics` - Obtener métricas

### Usuarios (Admin)
- `GET /api/users` - Listar usuarios
- `POST /api/users` - Crear usuario
- `PUT /api/users/<id>` - Actualizar usuario

---

## 🐛 Solución de Problemas

### Puerto 5000 en uso
```bash
# Opción 1: Cambiar puerto en docker-compose.yaml
# Cambiar: "5000:5000" → "8000:5000"

# Opción 2: Liberar puerto
# Windows: netstat -ano | findstr :5000
# Linux/Mac: lsof -i :5000
# Luego: kill -9 <PID>
```

### La BD no se crea
```bash
# Con Docker
docker-compose down
docker-compose up --build

# Local
rm src/backend/team_portal.db
python app.py
```

### No puedo entrar a la aplicación
- Verifica que http://localhost:5000 está accesible
- Verifica que Docker está corriendo: `docker ps`
- Revisa los logs: `docker-compose logs`

---

## ✅ Checklist de Requisitos Cumplidos

### 1. Acceso y Usuarios ✅
- [x] Login/logout funcional
- [x] 2 roles: Admin y Usuario
- [x] Gestión de usuarios (CRUD)
- [x] Al menos un admin siempre activo
- [x] Cuentas de demostración incluidas

### 2. Tablero de Notas ✅
- [x] Notas tipo post-it en lienzo libre
- [x] Crear, editar, eliminar notas
- [x] Estados: Pendiente, En curso, Hecho
- [x] **Drag & drop funcional**
- [x] Posiciones guardadas automáticamente
- [x] Persistencia en BD

### 3. Dashboard ✅
- [x] Total de notas
- [x] Distribución por estado
- [x] Métricas en tiempo real

### 4. Ejecutable en Local ✅
- [x] Docker Compose configurado
- [x] BD embebida (SQLite)
- [x] Sin dependencias externas
- [x] Datos de demo incluidos

### 5. Arquitectura AWS ✅
- [x] SAM Template (CloudFormation)
- [x] Lambda para métricas
- [x] S3 + CloudFront para frontend
- [x] EC2 para backend
- [x] Scripts de despliegue documentados

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
Edita `.env` para cambiar configuración:
```
FLASK_ENV=development  # Cambiar a 'production'
JWT_SECRET_KEY=...     # Cambiar la clave secreta
DATABASE_URL=...       # Cambiar BD si es necesario
PORT=5000              # Cambiar puerto
```



## 🎓 Tecnologías Utilizadas

- **Backend**: Flask (Python 3.11)
- **Base de datos**: SQLite
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Contenedorización**: Docker, Docker Compose
- **Infraestructura**: AWS SAM, CloudFormation
- **Seguridad**: Werkzeug (password hashing), sesiones de Flask

---

## 📄 Licencia

Este proyecto es parte de una prueba técnica y está disponible para revisión.

---

**Versión**: 1.0.0  
**Última actualización**: 2026-09-17  

