output "instance_id" {
  value       = aws_instance.grafana.id
  description = "EC2 instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.grafana.public_ip
  description = "Public IP"
}

output "public_dns" {
  value       = aws_instance.grafana.public_dns
  description = "Public DNS"
}

output "grafana_url" {
  value       = "http://${aws_instance.grafana.public_ip}:3000/"
  description = "Grafana URL"
}
