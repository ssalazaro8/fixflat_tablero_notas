# Script para configurar el entorno local en Windows

Write-Host ""
Write-Host "============================================"
Write-Host "   Portal de Equipo - Setup Local"
Write-Host "============================================"
Write-Host ""

# Verificar Python
Write-Host "Verificando Python..."
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Python no está instalado o no está en PATH"
    Write-Host ""
    Write-Host "Descarga Python desde: https://www.python.org/"
    Write-Host "Asegúrate de marcar 'Add Python to PATH' durante la instalación"
    Write-Host ""
    exit 1
}

Write-Host "[OK] $pythonVersion"
Write-Host ""

# Crear ambiente virtual
Write-Host "Creando ambiente virtual..."
if (Test-Path "venv") {
    Write-Host "El ambiente virtual ya existe. Usando el existente."
} else {
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] No se pudo crear el ambiente virtual"
        exit 1
    }
    Write-Host "[OK] Ambiente virtual creado"
}

Write-Host ""

# Activar ambiente virtual
Write-Host "Activando ambiente virtual..."
& ".\venv\Scripts\Activate.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No se pudo activar el ambiente virtual"
    exit 1
}

Write-Host "[OK] Ambiente virtual activado"
Write-Host ""

# Instalar dependencias
Write-Host "Instalando dependencias Python..."
Set-Location src/backend
pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar dependencias"
    Set-Location ..\..
    exit 1
}

Write-Host "[OK] Dependencias instaladas"
Set-Location ..\..

Write-Host ""
Write-Host "============================================"
Write-Host "   Setup completado exitosamente!"
Write-Host "============================================"
Write-Host ""
Write-Host "Para iniciar la aplicación:"
Write-Host "  1. Abre PowerShell en esta carpeta"
Write-Host "  2. Ejecuta: .\venv\Scripts\Activate.ps1"
Write-Host "  3. Ejecuta: python src/backend/app.py"
Write-Host ""
Write-Host "La aplicación estará disponible en http://localhost:5000"
Write-Host ""
