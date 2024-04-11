/* Provisions and configures a staging instance to be used with Lyria
to create AMIs from.
*/

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
##################################################
# Data Sources
##################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_s3_bucket" "storage" {
  bucket = "${var.name_prefix}-storage-2024-dev"
}

##################################################
# Instance Profile - allows dev bucket access
##################################################


resource "aws_iam_role_policy" "staging_policy" {
  name = "${var.name_prefix}_read_only_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PerformBucketActions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
        ],
        "Resource" : [
          "${data.aws_s3_bucket.storage.arn}",
          "${data.aws_s3_bucket.storage.arn}/*"
        ]
      }
    ]
  })
  role = aws_iam_role.staging_bucket_role.name
}

resource "aws_iam_role" "staging_bucket_role" {
  name = "${var.name_prefix}_staging_bucket_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "asg_bucket_profile" {
  name = "${var.name_prefix}_instance_profile"
  role = aws_iam_role.staging_bucket_role.name
}

##################################################
# Staging Instance
##################################################

resource "aws_instance" "staging_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.staging_instance.name]
  tags = {
    Name = "${var.name_prefix}-staging-instance"
  }
  iam_instance_profile = aws_iam_instance_profile.asg_bucket_profile.name
  # updates instance and installs docker
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install ca-certificates curl -y
              install -m 0755 -d /etc/apt/keyrings -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
              EOF
}

##################################################
# Security Group
##################################################

resource "aws_security_group" "staging_instance" {
  name        = "${var.name_prefix}_staging_sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.staging_instance.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.staging_instance.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = aws_security_group.staging_instance.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}