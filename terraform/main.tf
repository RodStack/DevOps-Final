provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repository_name
}

# Aquí irían más recursos de AWS según necesites