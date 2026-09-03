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
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.micro"

  associate_public_ip_address = true
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = aws_key_pair.this.key_name

  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("./install-grafana.sh")
}


##############################################
######## Write your code here -> #############
##############################################

# 1 - create policy
resource "aws_iam_policy" "main" {
  name = "grafana_policy"
  path = "/"
  description = "Policy for Grafana instance"

  policy = file("${path.module}/grafana-policy.json")
}

# 2 - create role
resource "aws_iam_role" "main" {
  name = "grafana_role"

  assume_role_policy = file("${path.module}/grafana-role-asume-policy.json")
}

# 3 - create policy to role attachment
resource "aws_iam_role_policy_attachment" "main" {
  role = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# 4 - create instance profile 
resource "aws_iam_instance_profile" "main" {
  name = "grafana-instance-profile"
  role = aws_iam_role.main.name
}