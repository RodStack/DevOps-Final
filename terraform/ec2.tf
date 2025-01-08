# Data source para obtener la AMI más reciente de Amazon Linux 2
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

# Grupo de seguridad para la instancia EC2
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

# Instancia EC2
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_name

  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              curl -sL https://rpm.nodesource.com/setup_14.x | bash -
              yum install -y nodejs
              mkdir -p /app
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
                  console.log('API running on port ' + port);
              });
              EOL

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

              cat > /etc/systemd/system/node-app.service << 'EOL'
              [Unit]
              Description=Node.js API Application
              After=network.target

              [Service]
              Type=simple
              User=root
              WorkingDirectory=/app
              ExecStart=/usr/bin/node app.js
              Restart=on-failure

              [Install]
              WantedBy=multi-user.target
              EOL

              cd /app
              npm install
              systemctl enable node-app
              systemctl start node-app
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