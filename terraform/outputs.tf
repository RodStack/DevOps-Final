output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "instance_public_dns" {
  value = aws_instance.app.public_dns
}