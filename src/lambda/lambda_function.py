"""
AWS Lambda function para calcular métricas del dashboard.
Esta función es llamada por la API para obtener estadísticas de notas.

En la arquitectura AWS:
- Se invoca vía API Gateway
- Accede a la BD en RDS o DynamoDB
- Retorna las métricas al frontend
"""

import json
import boto3
from typing import Dict, Any

# En local, esta función es simulada por el endpoint /api/dashboard/metrics en la API Flask
# En AWS, esta función usaría RDS o DynamoDB para acceder a los datos

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handler principal de Lambda.

    Args:
        event: Evento de API Gateway
        context: Contexto de Lambda

    Returns:
        Respuesta con métricas del dashboard
    """

    try:
        # En producción, aquí se accedería a la base de datos
        # Para este ejemplo, retornamos la estructura esperada

        # Simular cálculo de métricas
        metrics = {
            'total': 3,
            'distribution': {
                'Pendiente': 1,
                'En curso': 1,
                'Hecho': 1
            }
        }

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(metrics)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Error interno del servidor'})
        }

def calculate_metrics(db_connection) -> Dict[str, Any]:
    """
    Calcula las métricas del dashboard desde la BD.

    Args:
        db_connection: Conexión a la base de datos

    Returns:
        Diccionario con métricas
    """

    # Query para obtener el total de notas
    total = len(db_connection.query("SELECT COUNT(*) FROM notes"))

    # Query para obtener distribución por estado
    pending = len(db_connection.query("SELECT COUNT(*) FROM notes WHERE status = 'Pendiente'"))
    in_progress = len(db_connection.query("SELECT COUNT(*) FROM notes WHERE status = 'En curso'"))
    done = len(db_connection.query("SELECT COUNT(*) FROM notes WHERE status = 'Hecho'"))

    return {
        'total': total,
        'distribution': {
            'Pendiente': pending,
            'En curso': in_progress,
            'Hecho': done
        }
    }
