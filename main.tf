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

  user_data            = file("~/.ssh/id_rsa_azure.pub")
  iam_instance_profile = aws_iam_instance_profile.this.name
}

resource "aws_iam_policy" "this" {
  name   = "mate-grafana-policy"
  path   = "/"
  policy = file("./grafana-policy.json")
}

resource "aws_iam_role" "this" {
  name               = "mate-grafana-role"
  assume_role_policy = file("./grafana-role-asume-policy.json")
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name = "mate-grafana-instance-profile"
  role = aws_iam_role.this.name
}
