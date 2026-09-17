param(
    [string]$Environment = "dev",
    [string]$Region = "us-east-1",
    [string]$StackName = "team-portal-stack"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Team Portal - AWS Deployment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Validar que AWS CLI está instalado
Write-Host "Verificando AWS CLI..." -ForegroundColor Yellow
$awsVersion = aws --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS CLI no está instalado o no está en PATH" -ForegroundColor Red
    Write-Host "Descárgalo de: https://aws.amazon.com/cli/" -ForegroundColor Red
    exit 1
}
Write-Host "✓ AWS CLI encontrado: $awsVersion" -ForegroundColor Green

# Validar que SAM CLI está instalado
Write-Host "Verificando SAM CLI..." -ForegroundColor Yellow
$samVersion = sam --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: SAM CLI no está instalado" -ForegroundColor Red
    Write-Host "Descárgalo de: https://aws.amazon.com/serverless/sam/" -ForegroundColor Red
    exit 1
}
Write-Host "✓ SAM CLI encontrado: $samVersion" -ForegroundColor Green

# Validar que Docker está instalado
Write-Host "Verificando Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker no está instalado" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker encontrado: $dockerVersion" -ForegroundColor Green

# Verificar credenciales AWS
Write-Host "Verificando credenciales AWS..." -ForegroundColor Yellow
$identity = aws sts get-caller-identity --region $Region 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudieron obtener credenciales AWS" -ForegroundColor Red
    Write-Host "Configura AWS CLI con: aws configure" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Credenciales AWS válidas" -ForegroundColor Green
Write-Host "   $identity" -ForegroundColor Gray

Write-Host ""
Write-Host "Parámetros de despliegue:" -ForegroundColor Cyan
Write-Host "  Environment: $Environment"
Write-Host "  Región AWS: $Region"
Write-Host "  Stack Name: $StackName"
Write-Host ""

# Build del código
Write-Host "Compilando aplicación..." -ForegroundColor Yellow
sam build --use-container
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Error durante el build" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Build completado" -ForegroundColor Green
Write-Host ""

# Deploy
Write-Host "Desplegando en AWS..." -ForegroundColor Yellow
sam deploy `
    --stack-name $StackName `
    --region $Region `
    --parameter-overrides `
        Environment=$Environment `
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM `
    --no-confirm-changeset `
    --no-fail-on-empty-changeset

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Error durante el deployment" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ DEPLOYMENT EXITOSO" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Obtener outputs
Write-Host "Obteniendo información del stack..." -ForegroundColor Yellow
$outputs = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query 'Stacks[0].Outputs' `
    --output json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "URLS Y ENDPOINTS:" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan

    $outputObj = $outputs | ConvertFrom-Json
    foreach ($output in $outputObj) {
        Write-Host "$($output.OutputKey):" -ForegroundColor White
        Write-Host "  $($output.OutputValue)" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "1. Espera 2-3 minutos a que la instancia EC2 esté lista"
Write-Host "2. Sube el frontend a S3:"
Write-Host "   aws s3 sync src/backend/static s3://team-portal-frontend-[ID]-$Environment --region $Region"
Write-Host "3. Accede a través de CloudFront (URL arriba)"
Write-Host ""
Write-Host "Para limpiar recursos:" -ForegroundColor Yellow
Write-Host "aws cloudformation delete-stack --stack-name $StackName --region $Region"
Write-Host ""
