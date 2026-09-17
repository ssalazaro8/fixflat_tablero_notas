#!/bin/bash

# Script para iniciar la aplicación en Unix/Linux/Mac

echo ""
echo "============================================"
echo "   Portal de Equipo - Iniciador Local"
echo "============================================"
echo ""

# Verificar si Docker está disponible
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker no está instalado o no está en PATH"
    echo ""
    echo "Para instalar Docker, visita: https://www.docker.com/products/docker-desktop"
    echo ""
    exit 1
fi

echo "[OK] Docker encontrado"
echo ""

# Verificar docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "[ERROR] Docker Compose no está instalado"
    echo ""
    exit 1
fi

echo "[OK] Docker Compose encontrado"
echo ""

# Iniciar contenedores
echo "Iniciando contenedores..."
docker-compose up --build

echo ""
echo "La aplicación se ha detenido."
echo ""
