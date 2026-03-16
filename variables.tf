variable "subnet_id" {
  type        = string
  description = "ID of the VPC subnet, you deployed in the previous task."
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group, you deployed in the previous task."
}

variable "ami_owners" {
  type        = list(string)
  description = "AMI owners."
}

variable "ami_name_pattern" {
  type        = string
  description = "AMI name pattern."
}

variable "key_pair_name" {
  type        = string
  description = "Name of the EC2 key pair to create/use."
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key used for the EC2 key pair."
}

variable "resource_name_tag" {
  type        = string
  description = "Value for the Name tag across resources."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Grafana host."
}

variable "user_data_path" {
  type        = string
  description = "Path to the user data script for instance bootstrap."
}
