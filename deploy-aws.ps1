param(
    [string]$Environment = "dev",
    [string]$Region = "us-east-1",
    [string]$StackName = "team-portal-stack"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Team Portal - AWS Deployment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Validar AWS CLI
Write-Host "Verificando AWS CLI..." -ForegroundColor Yellow
$awsVersion = aws --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS CLI no instalado" -ForegroundColor Red
    exit 1
}
Write-Host "✓ AWS CLI OK: $awsVersion" -ForegroundColor Green

# Validar SAM CLI
Write-Host "Verificando SAM CLI..." -ForegroundColor Yellow
$samVersion = sam --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: SAM CLI no instalado" -ForegroundColor Red
    exit 1
}
Write-Host "✓ SAM CLI OK: $samVersion" -ForegroundColor Green

# Validar Docker
Write-Host "Verificando Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no instalado" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker OK: $dockerVersion" -ForegroundColor Green

# Validar credenciales AWS
Write-Host "Verificando credenciales AWS..." -ForegroundColor Yellow
$identity = aws sts get-caller-identity --region $Region 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Credenciales AWS no válidas" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Credenciales OK" -ForegroundColor Green

Write-Host ""
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Region: $Region" -ForegroundColor Cyan
Write-Host "Stack: $StackName" -ForegroundColor Cyan
Write-Host ""

# Build
Write-Host "Compilando aplicación..." -ForegroundColor Yellow
sam build --use-container
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR en build" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build OK" -ForegroundColor Green
Write-Host ""

# Deploy
Write-Host "Desplegando en AWS..." -ForegroundColor Yellow
sam deploy `
    --stack-name $StackName `
    --region $Region `
    --parameter-overrides Environment=$Environment `
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM `
    --no-confirm-changeset `
    --no-fail-on-empty-changeset

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR en deployment" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ DEPLOYMENT EXITOSO" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Outputs
Write-Host "Obteniendo informacion del stack..." -ForegroundColor Yellow
$outputs = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query 'Stacks[0].Outputs' `
    --output json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "URLS Y ENDPOINTS:" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host $outputs
    Write-Host ""
}

Write-Host "PROXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "1. Espera 2-3 minutos a que EC2 inicie"
Write-Host "2. Sube frontend a S3:"
Write-Host "   aws s3 sync src/backend/static s3://team-portal-frontend-965472235051-$Environment --region $Region"
Write-Host "3. Accede a CloudFront (URL en outputs arriba)"
Write-Host ""
