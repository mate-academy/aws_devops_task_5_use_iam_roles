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

# ── SSH key pair ───────────────────────────
resource "aws_key_pair" "grafana" {
  key_name   = "aws-grafana-lab-key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

# ── EC2 instance with Grafana ──────────────
resource "aws_instance" "grafana" {
  ami                         = data.aws_ami.this.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.grafana.key_name
  iam_instance_profile        = aws_iam_instance_profile.grafana.name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("${path.module}/install-grafana.sh")
}

# ── IAM Policy для Grafana ─────────────────
resource "aws_iam_policy" "grafana" {
  name        = "grafana-cloudwatch-read"
  description = "Policy for Grafana to read CloudWatch metrics/logs"
  policy      = file("${path.module}/grafana-policy.json")
}

# ── IAM Role ───────────────────────────────
resource "aws_iam_role" "grafana" {
  name               = "grafana-ec2-role"
  assume_role_policy = file("${path.module}/grafana-role-asume-policy.json")
}

# ── Attach Policy to Role ──────────────────
resource "aws_iam_role_policy_attachment" "grafana_attach" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana.arn
}

# ── Instance Profile ───────────────────────
resource "aws_iam_instance_profile" "grafana" {
  name = "grafana-ec2-instance-profile"
  role = aws_iam_role.grafana.name
}
