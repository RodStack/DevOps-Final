data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for app servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "app-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = <<-EOF
              #!/bin/bash
              # Actualizar el sistema
              yum update -y

              # Instalar Node.js
              curl -sL https://rpm.nodesource.com/setup_14.x | bash -
              yum install -y nodejs

              # Crear directorio de la aplicación
              mkdir -p /app
              
              # Crear archivo app.js
              cat > /app/app.js << 'EOL'
              const express = require('express');
              const app = express();
              const port = 80;

              app.use(express.json());

              app.get('/health', (req, res) => {
                  res.status(200).json({ status: 'ok', message: 'API is running' });
              });

              app.get('/api/info', (req, res) => {
                  res.json({
                      service: 'Demo API',
                      version: '1.0.0',
                      timestamp: new Date()
                  });
              });

              app.get('/api/hello', (req, res) => {
                  res.json({
                      message: 'Hello, DevOps!'
                  });
              });

              app.listen(port, () => {
                  console.log(`API running on port ${port}`);
              });
              EOL

              # Crear package.json
              cat > /app/package.json << 'EOL'
              {
                "name": "simple-api",
                "version": "1.0.0",
                "description": "Simple API for DevOps demo",
                "main": "app.js",
                "scripts": {
                  "start": "node app.js"
                },
                "dependencies": {
                  "express": "^4.18.2"
                }
              }
              EOL

              # Instalar dependencias y ejecutar la aplicación
              cd /app
              npm install
              npm start &
              EOF

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  tags = {
    Name        = "app-server"
    Environment = var.environment
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}