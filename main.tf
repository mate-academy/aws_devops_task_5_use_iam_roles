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
  public_key = file("~/.ssh/mate-aws-grafana.pub")

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

  key_name             = aws_key_pair.this.key_name
  iam_instance_profile = aws_iam_instance_profile.grafana.name

  user_data = file("${path.module}/install-grafana.sh")

  tags = {
    Name = "mate-aws-grafana-lab"
  }

}

resource "aws_iam_policy" "grafana" {
  name        = "mate-aws-grafana-cloudwatch-policy"
  description = "Allows Grafana to read CloudWatch metrics and logs"
  policy      = file("${path.module}/grafana-policy.json")
}

resource "aws_iam_role" "grafana" {
  name               = "mate-aws-grafana-role"
  assume_role_policy = file("${path.module}/grafana-role-asume-policy.json")
}

resource "aws_iam_role_policy_attachment" "grafana" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana.arn
}

resource "aws_iam_instance_profile" "grafana" {
  name = "mate-aws-grafana-instance-profile"
  role = aws_iam_role.grafana.name
}
