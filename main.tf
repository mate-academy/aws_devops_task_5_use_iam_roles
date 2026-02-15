data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "aws-grafana-lab-key"
  public_key = file("~/.ssh/terraform_key.pub")

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = aws_key_pair.this.key_name

  iam_instance_profile = aws_iam_instance_profile.grafana.name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("./install-grafana.sh")
}


##############################################
######## Write your code here -> #############
##############################################

# 1 - create policy 
resource "aws_iam_policy" "grafana" {
  name        = "grafana-cloudwatch-policy"
  path        = "/"
  description = "Policy for Grafana to read CloudWatch metrics and logs"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = file("${path.module}/grafana-policy.json")
}

# 2 - create role 

resource "aws_iam_role" "grafana" {
  name = "grafana-ec2-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = file("${path.module}/grafana-role-asume-policy.json")

  tags = {
    tag-key = "tag-value"
  }
}

# 3 - create policy to role attachment 
resource "aws_iam_role_policy_attachment" "grafana_attach" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana.arn
}

# 4 - create instance profile 

resource "aws_iam_instance_profile" "grafana" {
  name = "grafana-ec2-instance-profile"
  role = aws_iam_role.grafana.name
}