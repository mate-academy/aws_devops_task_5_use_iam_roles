variable "subnet_id" {
  description = "ID of the VPC subnet from previous task"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group from previous task"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # у eu-north-1 підходить для free tier
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "aws-grafana-lab-key"
}

variable "ssh_public_key_path" {
  description = "Path to RSA public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
