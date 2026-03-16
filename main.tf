data "aws_ami" "this" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
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
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = {
    Name = var.resource_name_tag
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = var.instance_type

  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  key_name = aws_key_pair.this.key_name

  tags = {
    Name = var.resource_name_tag
  }

  user_data = file(var.user_data_path)
}

resource "aws_iam_policy" "policy" {
  name        = "grafana_policy"
  path        = "/"
  description = "My test policy"

  policy = file("./grafana-policy.json")
}

resource "aws_iam_role" "role" {
  name = "grafana_role"

  assume_role_policy = file("grafana-role-assume-policy.json")

  tags = {
    tag-key = "grafana_role"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "grafana_instance_profile"
  role = aws_iam_role.role.name
}

