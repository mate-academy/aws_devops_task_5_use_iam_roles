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
  instance_type = "t3.micro"

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


##############################################
######## Write your code here -> #############
##############################################

# 1 - create policy 

# 2 - create role 

# 3 - create policy to role attachment 

# 4 - create instance profile 

resource "aws_iam_policy" "grafana_policy" {
  name        = "grafana_policy"
  path        = "/"
  description = "Policy for Grafana access to AWS metrics and logs"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "AllowReadingMetricsFromCloudWatch"

        Effect = "Allow"

        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ]

        Resource = "*"
      },

      {
        Sid = "AllowReadingResourceMetricsFromPerformanceInsights"

        Effect = "Allow"

        Action = [
          "pi:GetResourceMetrics"
        ]

        Resource = "*"
      },

      {
        Sid = "AllowReadingLogsFromCloudWatch"

        Effect = "Allow"

        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ]

        Resource = "*"
      },

      {
        Sid = "AllowReadingTagsInstancesRegionsFromEC2"

        Effect = "Allow"

        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]

        Resource = "*"
      },

      {
        Sid = "AllowReadingResourcesForTags"

        Effect = "Allow"

        Action = [
          "tag:GetResources"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "grafana_role" {
  name = "grafana_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]

        Effect = "Allow"

        Sid = ""

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "grafana_role"
  }
}

resource "aws_iam_role_policy_attachment" "grafana-attach" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

resource "aws_iam_instance_profile" "grafana_profile" {
  name = "test_profile"
  role = aws_iam_role.grafana_role.name
}
