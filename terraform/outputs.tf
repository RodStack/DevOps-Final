output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_public_dns" {
  value = aws_instance.app.public_dns
  description = "Public DNS of the EC2 instance"
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.main.url
}