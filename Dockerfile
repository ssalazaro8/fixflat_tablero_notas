FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependencias Python
COPY src/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY src/backend/ .

# Crear carpeta para la BD
RUN mkdir -p /data

# Exponer puerto
EXPOSE 5000

# Comando para ejecutar la aplicación
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
