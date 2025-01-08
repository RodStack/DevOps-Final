variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "Nombre del par de claves EC2"
  type        = string
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "fuenzalida.rodrigo@gmail.com"
}