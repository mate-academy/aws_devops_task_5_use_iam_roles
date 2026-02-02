data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
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

resource "aws_iam_policy" "grafana_policy" {
  name   = "GrafanaCloudWatchPolicy"
  policy = file("grafana-policy.json")
}

resource "aws_iam_role" "grafana" {
  name               = "GrafanaEC2Role"
  assume_role_policy = file("grafana-role-asume-policy.json")
}

resource "aws_iam_role_policy_attachment" "grafana_attach_policy" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

resource "aws_iam_instance_profile" "grafana_profile" {
  name = "GrafanaInstanceProfile"
  role = aws_iam_role.grafana.name
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]

  key_name = aws_key_pair.this.key_name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("./install-grafana.sh")

  iam_instance_profile = aws_iam_instance_profile.grafana_profile.name
}
