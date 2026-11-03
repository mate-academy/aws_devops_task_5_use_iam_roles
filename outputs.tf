output "instance_public_ip" {
  description = "Public IPv4 address of the Grafana EC2 instance."
  value       = aws_instance.this.public_ip
  sensitive   = false
}

output "grafana_url" {
  description = "URL of the Grafana web interface."
  value       = "http://${aws_instance.this.public_ip}:3000/"
  sensitive   = false
}

output "grafana_iam_role_arn" {
  description = "ARN of the IAM role assigned to the Grafana EC2 instance."
  value       = aws_iam_role.grafana.arn
  sensitive   = false
}
