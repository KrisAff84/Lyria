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
  description = "lyria_v2"
  default     = "ami-08e84ab05e2eaa08f"
}

variable "ami_bastion" {
  description = "AMI to be used for bastion host"
  default     = "ami-0e83be366243f524a"
}

variable "key_name" {
  description = "SSH key name"
  default     = "lyria_2024"
}

variable "my_ip" {
  description = "Your IP address"
  default     = "24.162.52.74/32"
}

####################################################
#### Buckets
####################################################

variable "bucket_arn" {
  description = "ARN of the S3 Storage bucket"
  default     = "arn:aws:s3:::lyria-storage-2024-prod"
}

variable "logging_bucket_name" {
  description = "Name of the logging bucket"
  default     = "lyria-logs-2024"
}

variable "logging_bucket_endpoint" {
  description = "Endpoint for the logging bucket"
  default     = "lyria-logs-2024.s3.amazonaws.com"
}

####################################################
#### Certificate
####################################################

variable "ssl_policy" {
  description = "SSL policy for the load balancer"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  default     = "arn:aws:acm:us-east-1:637423562225:certificate/2c63d249-2e6e-49fb-99ae-b434603081f0"
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