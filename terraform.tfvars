# Networking
subnet_id         = "subnet-0f505455b2df01be3"
security_group_id = "sg-0dde7e9651d3cbd07"

# AMI selection
ami_owners       = ["amazon"]
ami_name_pattern = "amzn2-ami-hvm-*-gp2"

# Access
key_pair_name   = "aws-grafana-lab-key"
public_key_path = "~/.ssh/id_rsa.pub"

# Compute
instance_type     = "t2.micro"
resource_name_tag = "mate-aws-grafana-lab"

# Bootstrap
user_data_path = "./install-grafana.sh"
