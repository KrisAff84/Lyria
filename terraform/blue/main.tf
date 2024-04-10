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
# Network Configuration
###########################################

resource "aws_vpc" "main" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# ############# Public Subnet #############
# Needed for Bastion Host only

resource "aws_subnet" "public" {
  vpc_id                                         = aws_vpc.main.id
  availability_zone                              = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  enable_dns64                                   = true
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)
  cidr_block                                     = cidrsubnet(var.vpc_cidr, 4, 0)
  tags = {
    Name = "${var.name_prefix}-public"
  }
}

############# Private Subnets #############

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 7)
  availability_zone = data.aws_availability_zones.available.names[0]
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 13)
  tags = {
    Name = "${var.name_prefix}-private-1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 8)
  availability_zone = data.aws_availability_zones.available.names[1]
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 14)
  tags = {
    Name = "${var.name_prefix}-private-2"
  }
}
resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 9)
  availability_zone = data.aws_availability_zones.available.names[2]
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 15)
  tags = {
    Name = "${var.name_prefix}-private-3"
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

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


############ Network Connections ############

########## VPC Endpoint ########## 
## For application access to S3 ##

resource "aws_vpc_endpoint" "bucket_endpoint" {
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_id       = aws_vpc.main.id
  route_table_ids = [
    aws_route_table.private.id
  ]
  tags = {
    Name = "${var.name_prefix}-bucket-endpoint"
  }
}

########## Private Route Table & Associations ##########

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}


###########################################
# Launch Template
###########################################

resource "aws_launch_template" "asg_lt" {
  name          = "${var.name_prefix}_asg_lt"
  image_id      = var.ami_main
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.asg_elb_access_sg.id,
    aws_security_group.asg_ssh_access_sg.id
  ]
  iam_instance_profile {
    arn = aws_iam_instance_profile.asg_bucket_profile.arn
  }

}

###########################################
# Autoscaling Group
###########################################

resource "aws_autoscaling_group" "asg" {
  name = "${var.name_prefix}_asg"
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = aws_launch_template.asg_lt.latest_version
  }
  max_size          = 3
  min_size          = 1
  health_check_type = "ELB"
  desired_capacity  = 1
  vpc_zone_identifier = [
    aws_subnet.private1.id,
    aws_subnet.private2.id,
    aws_subnet.private3.id
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      auto_rollback          = true
      min_healthy_percentage = 100
    }
  }
  target_group_arns = [
    aws_lb_target_group.lb_tg.arn
  ]
  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupTotalInstances",
    "GroupInServiceCapacity",
    "GroupTotalCapacity"
  ]
}

resource "aws_autoscaling_policy" "main" {
  name                   = "${var.name_prefix}_asg_policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

###########################################
# Load Balancer
###########################################

resource "aws_lb" "elb" {
  name            = "${var.name_prefix}-elb"
  internal        = true
  security_groups = [aws_security_group.elb_sg.id]
  ip_address_type = "dualstack"
  subnets = [
    aws_subnet.private1.id,
    aws_subnet.private2.id,
    aws_subnet.private3.id
  ]
  access_logs {
    bucket  = "lyria-logs"
    prefix  = "elb_logs"
    enabled = true
  }
}
resource "aws_lb_target_group" "lb_tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 100
    path                = "/"
    port                = "traffic-port"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
  port              = 80
  protocol          = "HTTP"
  # Add the blocks below when ready for certificate
  #   default_action {
  #     type = "redirect"
  #     redirect {
  #       protocol    = "HTTPS"
  #       port        = "443"
  #       status_code = "HTTP_301"
  #     }
  #   }
  # }
  # resource "aws_lb_listener" "https" {
  #   load_balancer_arn = aws_lb.elb.arn
  #   port              = 443
  #   protocol          = "HTTPS"
  #   ssl_policy        = var.ssl_policy
  #   certificate_arn   = var.elb_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

###########################################
# Bastion Host
# Everything in this block can be commented out 
# if a bastion host is unneeded
###########################################

# resource "aws_instance" "bastion" {
#   ami           = var.ami_bastion
#   instance_type = var.instance_type
#   key_name      = var.key_name
#   vpc_security_group_ids = [
#     aws_security_group.bastion_sg.id
#   ]
#   subnet_id = aws_subnet.public1.id
#   tags = {
#     Name = "${var.name_prefix}-bastion"
#   }
# }

# output "bastion_ip" {
#   description = "Public IP of the bastion host"
#   value       = aws_instance.bastion.public_ip
# }

# output "bastion_instance_id" {
#   description = "Instance ID of the bastion host"
#   value       = aws_instance.bastion.id
# }

##################################################
# Security Groups
##################################################

############# ASG Security Groups ############

######### Access From Load Balancer ############

resource "aws_security_group" "asg_elb_access_sg" {
  name        = "${var.name_prefix}_asg_elb_access_sg"
  description = "Allow HTTP access from load balancer to Autoscaling Group"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "Allow HTTP from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }
  ingress {
    description     = "Allow HTTPS from Load Balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }
}

############## SSH from Bastion Host ##############

resource "aws_security_group" "asg_ssh_access_sg" {
  name        = "${var.name_prefix}_asg_ssh_access_sg"
  description = "Allow SSH access from Bastion Host"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "Allow SSH from Bastion Host"
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

############## Bastion Host Security Group ##############

resource "aws_security_group" "bastion_sg" {
  name        = "${var.name_prefix}_bastion_sg"
  description = "Allow SSH access from My IP"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow SSH from my IP"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########## Load Balancer Security Group ##########

resource "aws_security_group" "elb_sg" {
  name        = "${var.name_prefix}_elb_sg"
  description = "Allow all access"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "local" {
  security_group_id        = aws_security_group.elb_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.elb_sg.id
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = aws_security_group.elb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
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

###########################################
# API Gateway
###########################################

resource "aws_apigatewayv2_api" "lyria" {
  name          = "${var.name_prefix}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_vpc_link" "lyria" {
  name               = "${var.name_prefix}-vpc-link"
  security_group_ids = [aws_security_group.elb_sg.id]
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id,
    aws_subnet.private3.id
  ]
}

resource "aws_apigatewayv2_route" "lyria" {
  api_id    = aws_apigatewayv2_api.lyria.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lyria.id}"
}

resource "aws_apigatewayv2_integration" "lyria" {
  api_id             = aws_apigatewayv2_api.lyria.id
  integration_type   = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri    = aws_lb_listener.http.arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.lyria.id
}

resource "aws_apigatewayv2_stage" "lyria" {
  api_id      = aws_apigatewayv2_api.lyria.id
  name        = "$default"
  auto_deploy = true
}

#######################################################
# CloudFront Distribution
#######################################################

resource "aws_cloudfront_distribution" "api" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Caches main Lyria site from API"
  aliases         = var.domain_aliases
  http_version    = "http2and3"
  tags = {
    Name    = "${var.name_prefix}-cloudfront-dist"
    Project = "Lyria"
    Use     = "Site_API"
  }
  origin {
    origin_id   = "api"
    domain_name = "${aws_apigatewayv2_api.lyria.id}.execute-api.${var.aws_region}.amazonaws.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  default_cache_behavior {
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = var.cache_policy_id
    origin_request_policy_id = var.origin_request_policy_id
    target_origin_id         = "api"
  }
  viewer_certificate {
    acm_certificate_arn      = var.cf_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"

  }
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}