#####################################
# Provider
#####################################

provider "aws" {
  profile = "admin-profile"
  region  = var.aws_region
}

###########################################
# Data Source - Gets AWS Availability Zones
###########################################

data "aws_availability_zones" "available" {
  state = "available"
}

###########################################
# Resource - VPC and Subnets
###########################################

resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = var.vpc_cidr
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

############# Public Subnets #############

resource "aws_subnet" "public1" {
  vpc_id                                         = aws_vpc.main.id
  availability_zone                              = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)
  cidr_block                                     = cidrsubnet(var.vpc_cidr, 4, 0)
  tags = {
    Name = "${var.name_prefix}-public-1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                                         = aws_vpc.main.id
  availability_zone                              = data.aws_availability_zones.available.names[1]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)
  cidr_block                                     = cidrsubnet(var.vpc_cidr, 4, 1)
  tags = {
    Name = "${var.name_prefix}-public-2"
  }
}

###########################################
# IGW and Public Route Table
###########################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

############ Public Route Table ############

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

########## Route Table Associations ##########

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


###########################################
# Instance
###########################################

resource "aws_instance" "lyria" {
  ami           = var.ami_main
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public1.id
  vpc_security_group_ids = [
    aws_security_group.lyria_http.id,
    aws_security_group.lyria_ssh.id
  ]
  iam_instance_profile = aws_iam_instance_profile.asg_bucket_profile.name
  tags = {
    Name = "${var.name_prefix}-instance"
  }
}

##################################################
# Security Groups
##################################################

resource "aws_security_group" "lyria_http" {
  name        = "${var.name_prefix}_http_sg"
  description = "Allow Internet Access"
  vpc_id      = aws_vpc.main.id
  ingress {
    description      = "Allow IPv6 HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }
  # ingress {
  #   description     = "Allow HTTPS from Load Balancer"
  #   from_port       = 443
  #   to_port         = 443
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.elb_sg.id]
  # }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "lyria_ssh" {
  name        = "${var.name_prefix}_ssh_sg"
  description = "Allow SSH Access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow IPv4 SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_4]
  }
  ingress {
    description      = "Allow IPv6 SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = [var.my_ip_6]
  }
}

#############################################
# Instance Profile - Allows Instances 
# Read/Write Access to S3 Bucket
#############################################

resource "aws_iam_role_policy" "policy" {
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
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
  role = aws_iam_role.asg_bucket_role.name
}

resource "aws_iam_role" "asg_bucket_role" {
  name = "${var.name_prefix}_asg_bucket_role"
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
  role = aws_iam_role.asg_bucket_role.name
}