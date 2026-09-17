#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}
STACK_NAME=${3:-team-portal-stack}

echo "========================================"
echo "Team Portal - AWS Deployment"
echo "========================================"
echo ""

# Validar que AWS CLI está instalado
echo "Verificando AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI no está instalado"
    echo "Descárgalo de: https://aws.amazon.com/cli/"
    exit 1
fi
echo "✓ AWS CLI encontrado: $(aws --version)"

# Validar que SAM CLI está instalado
echo "Verificando SAM CLI..."
if ! command -v sam &> /dev/null; then
    echo "ERROR: SAM CLI no está instalado"
    echo "Descárgalo de: https://aws.amazon.com/serverless/sam/"
    exit 1
fi
echo "✓ SAM CLI encontrado: $(sam --version)"

# Validar que Docker está instalado
echo "Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker no está instalado"
    exit 1
fi
echo "✓ Docker encontrado: $(docker --version)"

# Verificar credenciales AWS
echo "Verificando credenciales AWS..."
if ! aws sts get-caller-identity --region "$REGION" &> /dev/null; then
    echo "ERROR: No se pudieron obtener credenciales AWS"
    echo "Configura AWS CLI con: aws configure"
    exit 1
fi
echo "✓ Credenciales AWS válidas"

echo ""
echo "Parámetros de despliegue:"
echo "  Environment: $ENVIRONMENT"
echo "  Región AWS: $REGION"
echo "  Stack Name: $STACK_NAME"
echo ""

# Build del código
echo "Compilando aplicación..."
sam build --use-container
echo "✓ Build completado"
echo ""

# Deploy
echo "Desplegando en AWS..."
sam deploy \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --parameter-overrides \
        Environment="$ENVIRONMENT" \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --no-confirm-changeset \
    --no-fail-on-empty-changeset

echo ""
echo "========================================"
echo "✓ DEPLOYMENT EXITOSO"
echo "========================================"
echo ""

# Obtener outputs
echo "Obteniendo información del stack..."
echo ""
echo "URLS Y ENDPOINTS:"
echo "========================================"
aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table

echo ""
echo "PRÓXIMOS PASOS:"
echo "1. Espera 2-3 minutos a que la instancia EC2 esté lista"
echo "2. Sube el frontend a S3:"
echo "   aws s3 sync src/backend/static s3://team-portal-frontend-[ID]-$ENVIRONMENT --region $REGION"
echo "3. Accede a través de CloudFront (URL arriba)"
echo ""
echo "Para limpiar recursos:"
echo "aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION"
echo ""
