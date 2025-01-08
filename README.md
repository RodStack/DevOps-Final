# Desafío Final DevOps - AWS Infrastructure

## Descripción
Implementación de infraestructura en AWS usando **Terraform** y **GitHub Actions** para CI/CD, incluyendo una API simple en **Node.js**.

---

## Configuración Inicial

### Requisitos Previos
- Cuenta AWS
- Repositorio GitHub
- Par de claves EC2 en AWS (**key pair**)

### Configuración de Secretos en GitHub
1. Ir a **Settings > Secrets and variables > Actions**.
2. Configurar los **Secrets**:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
ECR_REPOSITORY
SNYK_TOKEN
TF_API_TOKEN
3. Configurar Variable
AWS_REGION


markdown
Copiar código
## Recursos AWS Creados

- **VPC** con subnet pública.
- **Instancia EC2** con Node.js API.
- **Función Lambda**.
- **Cola SQS**.
- **Tema SNS**.
- **Grupos de seguridad**.

---

## API Endpoints

Acceso a través de la IP pública de EC2:

- `http://<ip-publica>/health`
- `http://<ip-publica>/api/info`
- `http://<ip-publica>/api/hello`

---

## Destruir Infraestructura

1. Ir a **GitHub Actions**.
2. Seleccionar el workflow **Destroy Infrastructure**.
3. Hacer clic en **Run workflow**.

---

## Monitoreo y Logs

- **CloudWatch** configurado para:
  - Métricas de EC2.
  - Alarmas para CPU y estado de la instancia.
  - Logs en **CloudWatch Logs**.

---

## Seguridad

- Escaneo de código con **Snyk**.
- Grupo de seguridad limitado a puertos **22** y **80**.
- VPC con subnet pública configurada.

---

## Solución de Problemas

### Si el Despliegue Falla:
- Verificar credenciales AWS.
- Confirmar existencia del key pair.
- Revisar logs en **GitHub Actions**.
