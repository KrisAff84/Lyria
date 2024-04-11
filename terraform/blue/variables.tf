####################################################
#####    Permissions
####################################################

variable "access_key" {
  description = "AWS Access Key"
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  default     = ""
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS Profile"
  default     = "kris84"
}

####################################################
#####    Network
####################################################

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.1.0.0/16"
}

variable "name_prefix" {
  description = "Naming prefix for all resources"
  default     = "lyria-blue"
}

####################################################
####    EC2
####################################################

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_main" {
  description = "lyria_v7"
  default     = "ami-061c4969ee8ab2d85"
}

variable "ami_bastion" {
  description = "AMI to be used for bastion host"
  default     = "ami-0e83be366243f524a"
}

variable "key_name" {
  description = "SSH key name"
  default     = "lyria"
}

variable "my_ip" {
  description = "Your IP address"
  default     = "24.162.52.74/32"
}

####################################################
#### Storage Bucket
####################################################

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  default     = "arn:aws:s3:::lyria-storage-2024-dev"
}

####################################################
#### Certificate
####################################################

variable "elb_certificate_arn" {
  description = "ARN of the ACM certificate for the ELB"
  default     = "arn:aws:acm:us-east-2:835656321421:certificate/7aee737d-0e1f-4311-b1ff-c3b596d85168"
}

variable "ssl_policy" {
  description = "SSL policy for the load balancer"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "cf_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  default     = "arn:aws:acm:us-east-1:835656321421:certificate/150d0e5f-766e-4c68-9b25-944d8fb364fc"
}

variable "domain_aliases" {
  type        = list(string)
  description = "Domain aliases for the CloudFront distribution/SSL certificate"
  default = [
    "meettheafflerbaughs.com",
    "www.meettheafflerbaughs.com",
    "meetheafflerbaughs.com",
    "www.meetheafflerbaughs.com",
  ]
}

variable "cache_policy_id" {
  description = "ID of the cache policy for CloudFront"
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
}

variable "origin_request_policy_id" {
  description = "ID of the origin request policy for CloudFront"
  default     = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
}