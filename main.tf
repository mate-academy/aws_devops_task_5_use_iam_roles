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

  iam_instance_profile = aws_iam_instance_profile.grafana.name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("./install-grafana.sh")
}


##############################################
########### IAM Configuration ################
##############################################
resource "aws_iam_policy" "grafana" {
  name        = "mate-aws-grafana-lab"
  description = "Policy for Grafana to read metrics and logs from CloudWatch"
  policy      = file("${path.module}/grafana-policy.json")
}

resource "aws_iam_role" "grafana" {
  name               = "mate-aws-grafana-lab"
  assume_role_policy = file("${path.module}/grafana-role-asume-policy.json")
}

resource "aws_iam_role_policy_attachment" "grafana" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana.arn
}

resource "aws_iam_instance_profile" "grafana" {
  name = "mate-aws-grafana-lab"
  role = aws_iam_role.grafana.name
}
