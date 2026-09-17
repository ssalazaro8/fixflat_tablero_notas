@echo off
REM Script para iniciar la aplicación en Windows

echo.
echo ============================================
echo   Portal de Equipo - Iniciador Local
echo ============================================
echo.

REM Verificar si Docker está disponible
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker no está instalado o no está en PATH
    echo.
    echo Para instalar Docker, visita: https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

echo [OK] Docker encontrado
echo.

REM Verificar docker-compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose no está instalado
    echo.
    pause
    exit /b 1
)

echo [OK] Docker Compose encontrado
echo.

REM Iniciar contenedores
echo Iniciando contenedores...
docker-compose up --build

echo.
echo La aplicación se ha detenido.
echo.
pause
